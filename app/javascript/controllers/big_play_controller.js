import { Controller } from '@hotwired/stimulus'
import LargePlayAnimation from '../animation/large_play_animation'

const PLAYER_EVENTS = ['player:trackchanged', 'player:loading', 'player:playing', 'player:paused', 'player:queueended']

// The morphing play/pause button in a track or playlist header. Same animation
// the persistent #player bar uses, driven off the player's events filtered to
// this header's track (the row buttons get the same treatment via
// normal-playback). Scoped to its own SVG so it doesn't touch the #player's.
export default class extends Controller {
  static values = { trackId: Number }

  initialize() {
    const svg = this.element.querySelector('.largePlaySVG')
    if (svg) this.animation = new LargePlayAnimation(svg)
  }

  connect() {
    this.onPlayerEvent = (e) => this.syncPlayButton(e)
    PLAYER_EVENTS.forEach((type) => document.addEventListener(type, this.onPlayerEvent))
  }

  disconnect() {
    PLAYER_EVENTS.forEach((type) => document.removeEventListener(type, this.onPlayerEvent))
    if (this.animation) this.animation.reset()
    this.animState = null
    this.animPlayed = false
  }

  // Only react to events about this button's track; the queue ending or any
  // event for a different track returns it to the resting play icon.
  syncPlayButton(event) {
    if (!this.animation) return
    if (event.type === 'player:queueended') return this.toAnimState('paused')
    const id = event.detail && event.detail.track && event.detail.track.id
    if (this.hasTrackIdValue && id !== this.trackIdValue) return this.toAnimState('paused')
    if (event.type === 'player:playing') this.toAnimState('playing')
    else if (event.type === 'player:paused') this.toAnimState('paused')
    else this.toAnimState('loading')
  }

  toAnimState(state) {
    if (this.animState === state) return
    this.animState = state
    if (state === 'loading') {
      this.animation.loadingAnimation()
    } else if (state === 'playing') {
      // first play morphs play->pause; later resumes just snap to the pause icon
      if (this.animPlayed) this.animation.showPauseButton()
      else { this.animation.pausingAnimation(); this.animPlayed = true }
    } else {
      this.animation.showPlayButton()
    }
  }
}
