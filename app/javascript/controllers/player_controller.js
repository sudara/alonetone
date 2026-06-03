import { Controller } from '@hotwired/stimulus'
import * as Stitches from '@alonetone/stitches'
import Bugsnag from '@bugsnag/js'
import { gsap } from 'gsap'
import LargePlayAnimation from '../animation/large_play_animation'

// One audio engine for the whole app, constructed once and kept alive inside the
// data-turbo-permanent #player bar so it survives Turbo navigations.
let player

// namespace import so a missing Player export (before the stitches 2.0 branch
// ships it) doesn't break the webpack build
function engine() {
  if (player) return player
  if (!Stitches.Player) return null
  player = new Stitches.Player({
    autoAdvance: true,
    preloadNext: true,
    eventTarget: document,
    enableConsoleLogging: false,
  })
  return player
}

export default class extends Controller {
  static targets = ['image', 'imageLink', 'title', 'artist', 'time', 'waveform', 'waveformPoints', 'waveformReveal', 'loadedReveal', 'progress', 'seekBar']

  // must match the waveform svg viewBox width in _player.html.erb
  static WAVEFORM_WIDTH = 500

  initialize() {
    this.isPlaying = false
    this.durationKnown = false
    this.trackDuration = 0
    this.animation = new LargePlayAnimation(this.element.querySelector('.largePlaySVG'))
    this.setupPlayhead()
  }

  // tracklist:play@window — detail: { queue, startIndex }
  // Must stay synchronous from the originating click so stitches can unlock the
  // audio nodes while the user gesture is still on the stack (iOS).
  load(event) {
    const p = engine()
    if (!p) return
    this.reveal()
    p.setQueue(event.detail.queue, { startIndex: event.detail.startIndex, autoplay: true })
  }

  toggle() {
    const p = engine()
    if (p) p.toggle()
  }

  trackChanged(event) {
    const t = event.detail.track
    this.titleTarget.textContent = t.title || ''
    this.titleTarget.href = t.trackUrl || '#'
    this.artistTarget.textContent = t.artist || ''
    this.artistTarget.href = t.artistUrl || '#'
    if (this.hasImageLinkTarget) this.imageLinkTarget.href = t.artistUrl || '#'
    if (this.hasImageTarget && t.imageUrl) this.imageTarget.src = t.imageUrl
    this.loadWaveform(t.waveformUrl)
    this.resetPlayhead()
    this.seedDuration(t.duration)
    this.isPlaying = false
    this.timeTarget.textContent = this.trackDuration > 0 ? this.formatTime(this.trackDuration) : '0:00'
  }

  formatTime(totalSeconds) {
    const whole = Math.floor(totalSeconds)
    return `${Math.floor(whole / 60)}:${String(whole % 60).padStart(2, '0')}`
  }

  // The DB-known length lets the playhead start immediately and at the right
  // pace; without it we'd wait for the first timeupdate to learn the duration.
  seedDuration(duration) {
    const seconds = parseFloat(duration)
    if (!(seconds > 0)) return
    this.trackDuration = seconds
    this.timeline.duration(seconds)
    this.durationKnown = true
  }

  // Buffered-ahead fill. Divides by the same DB duration the playhead uses so
  // the loading highlight and the playhead share one denominator; the event's
  // own loadingPosition divides by the media element's flaky early duration.
  whileLoading(event) {
    if (!this.hasLoadedRevealTarget) return
    const seconds = this.trackDuration || event.detail.duration
    if (!(seconds > 0)) return
    const fraction = Math.min(1, event.detail.secondsLoaded / seconds)
    this.loadedRevealTarget.setAttribute('width', fraction * this.constructor.WAVEFORM_WIDTH)
  }

  // One track plays at a time, so the waveform is fetched on demand rather than
  // embedded in every tracklist row. The token guards against a slow response
  // for a track the listener has already skipped past.
  loadWaveform(url) {
    if (!this.hasWaveformPointsTarget) return
    this.waveformPointsTarget.setAttribute('points', '')
    if (!url) return
    const token = (this.waveformToken = (this.waveformToken || 0) + 1)
    fetch(url, { headers: { Accept: 'application/json' } })
      .then((r) => (r.ok ? r.json() : null))
      .then((data) => {
        if (data && token === this.waveformToken) this.waveformPointsTarget.setAttribute('points', data.points)
      })
      .catch(() => {})
  }

  loading() {
    this.animation.loadingAnimation()
  }

  playing() {
    this.isPlaying = true
    this.animation.pausingAnimation()
    this.startPlayhead()
  }

  timeUpdate(event) {
    const { percent, currentTimeFormatted, duration } = event.detail
    if (this.isPlaying) this.timeTarget.textContent = currentTimeFormatted
    if (duration) {
      if (this.timeline.duration() !== duration) this.timeline.duration(duration)
      if (!this.durationKnown) {
        this.durationKnown = true
        this.startPlayhead()
      }
    }
    if (Math.abs(percent - this.timeline.progress()) > 0.02) this.timeline.progress(percent)
  }

  paused() {
    this.isPlaying = false
    this.animation.showPlayButton()
    this.timeline.pause()
  }

  ended() {
    this.isPlaying = false
    this.timeline.pause()
  }

  queueEnded() {
    this.isPlaying = false
    this.animation.showPlayButton()
    this.resetPlayhead()
  }

  // The listen is recorded server-side when stitches fetches the mp3 url, so
  // this is a reserved hook rather than a second request.
  registerListen() {}

  seeked() {
    this.startPlayhead()
  }

  // Hold the playhead until the first timeupdate reports the real track length;
  // the timeline defaults to a 1s duration, so playing it before then sprints
  // the marker to ~25% and snaps it back once the duration lands.
  startPlayhead() {
    if (this.isPlaying && this.durationKnown) this.timeline.play()
  }

  error(event) {
    this.isPlaying = false
    this.animation.showPlayButton()
    const err = event.detail && event.detail.error
    if (err) {
      Bugsnag.notify(new Error(`MP3 Playback Error: ${err.code} ${err.message} ${err.fileName}`))
    }
  }

  skim(e) {
    if (!this.hasSeekBarTarget) return
    const offx = e.clientX - this.waveformTarget.getBoundingClientRect().left
    this.seekBarTarget.style.left = `${offx}px`
  }

  seek(e) {
    const p = engine()
    if (!p) return
    const rect = this.waveformTarget.getBoundingClientRect()
    const position = (e.clientX - rect.left) / rect.width
    p.seek(position)
    this.timeline.progress(position)
  }

  reveal() {
    this.element.hidden = false
    this.element.classList.add('visible')
  }

  setupPlayhead() {
    this.timeline = gsap.timeline({ paused: true, duration: 1 })
    if (this.hasProgressTarget) {
      this.timeline.to(this.progressTarget, { duration: 1, left: '100%', ease: 'none' }, 0)
    }
    if (this.hasWaveformRevealTarget) {
      this.timeline.to(this.waveformRevealTarget, { duration: 1, attr: { x: 0 }, ease: 'none' }, 0)
    }
  }

  resetPlayhead() {
    this.durationKnown = false
    this.trackDuration = 0
    this.resetLoadedFill()
    this.timeline.pause()
    this.timeline.progress(0)
    this.timeline.duration(1)
  }

  // Snap the buffered fill to empty without its width transition, so a new track
  // starts clean instead of "unwinding" the previous track's fill.
  resetLoadedFill() {
    if (!this.hasLoadedRevealTarget) return
    const el = this.loadedRevealTarget
    el.style.transition = 'none'
    el.setAttribute('width', 0)
    el.getBoundingClientRect()
    el.style.transition = ''
  }
}
