import { Controller } from '@hotwired/stimulus'

// Shared across every tracklist on the page so a box that connects after
// playback has started (Turbo frame load, sidebar swap) can mirror the
// persistent player's live state immediately.
let current = { id: null, state: null }

const trackId = (event) => (event.detail && event.detail.track && event.detail.track.id) || null

// Wraps a collection of track rows (e.g. a home page "box" or a playlist
// sidebar). On play it builds a queue from its rows in DOM order and hands it to
// the persistent #player. Playing a row in a different collection rebuilds the
// queue from scratch, so the queue always reflects the last collection the
// listener touched. Each row also mirrors the player's play/pause/loading state.
export default class extends Controller {
  static targets = ['track', 'bigPlay']

  connect() {
    // every player:* event carries detail.track, so each handler reads its own
    // track id rather than leaning on event ordering to keep `current` fresh
    this.onTrackChanged = (e) => { this.applyState(trackId(e), 'loading'); this.followCurrent(trackId(e)) }
    this.onPlaying = (e) => this.applyState(trackId(e), 'playing')
    this.onPaused = (e) => this.applyState(trackId(e), 'paused')
    this.onLoading = (e) => this.applyState(trackId(e), 'loading')
    this.onStopped = () => this.applyState(null, null)
    document.addEventListener('player:trackchanged', this.onTrackChanged)
    document.addEventListener('player:playing', this.onPlaying)
    document.addEventListener('player:paused', this.onPaused)
    document.addEventListener('player:loading', this.onLoading)
    document.addEventListener('player:queueended', this.onStopped)
    this.render()
  }

  disconnect() {
    document.removeEventListener('player:trackchanged', this.onTrackChanged)
    document.removeEventListener('player:playing', this.onPlaying)
    document.removeEventListener('player:paused', this.onPaused)
    document.removeEventListener('player:loading', this.onLoading)
    document.removeEventListener('player:queueended', this.onStopped)
  }

  // Clicking the row that's already loaded toggles the persistent player rather
  // than restarting it; any other row (re)builds the queue and starts playback.
  play(event) {
    event.preventDefault()
    const row = event.target.closest('[data-tracklist-target="track"]')
    if (!row) return
    if (parseInt(row.dataset.trackId, 10) === current.id) {
      this.dispatch('toggle', { target: window })
    } else {
      this.playRow(row)
    }
  }

  // The detail frame swaps without re-rendering the sidebar, so derive the
  // active row from whichever track URL Turbo just loaded. Keeps #playActive in
  // sync across clicks, back/forward, and direct navigation.
  syncActiveFromFrame(event) {
    if (event.target.id !== 'playlist-track') return
    const src = event.target.getAttribute('src')
    if (!src) return
    const path = new URL(src, window.location.origin).pathname
    const row = this.trackTargets.find((el) => el.dataset.trackPageUrl === path)
    if (row) this.markActive(row)
    this.render()
  }

  // The big player's play button isn't itself a row; act on whichever track the
  // page has marked active (the one shown in the detail frame), else the first.
  // Toggles if that track is already loaded, otherwise starts it.
  playActive(event) {
    if (event) event.preventDefault()
    const row = this.trackTargets.find((el) => el.classList.contains('active')) || this.trackTargets[0]
    if (!row) return
    if (parseInt(row.dataset.trackId, 10) === current.id) {
      this.dispatch('toggle', { target: window })
    } else {
      this.playRow(row)
    }
  }

  playRow(row) {
    // An eager-loaded detail frame has no src, so only swap it when this row
    // isn't already the one on screen - otherwise we'd reload (and detach) it.
    const wasActive = row.classList.contains('active')
    this.markActive(row)
    if (!wasActive) this.showTrackDetail(row)
    const startIndex = this.trackTargets.indexOf(row)
    const queue = this.trackTargets.map((el) => this.descriptor(el))
    this.dispatch('play', { target: window, detail: { queue, startIndex } })
  }

  // Stitches auto-advances without a click, so keep the playlist detail frame
  // and active row pointed at whatever is now playing. No-op off a playlist.
  followCurrent(id) {
    if (id == null || !document.getElementById('playlist-track')) return
    const row = this.trackTargets.find((el) => parseInt(el.dataset.trackId, 10) === id)
    if (!row || row.classList.contains('active')) return
    this.markActive(row)
    this.showTrackDetail(row)
  }

  // On a playlist, playing a track swaps the cover/detail frame to that track so
  // the layout matches what's playing. The frame doesn't exist elsewhere (home
  // boxes, single-track pages), so this is a no-op there.
  showTrackDetail(row) {
    const frame = document.getElementById('playlist-track')
    const url = row.dataset.trackPageUrl
    if (!frame || !url || frame.getAttribute('src') === url) return
    frame.setAttribute('src', url)
  }

  markActive(row) {
    this.trackTargets.forEach((el) => el.classList.toggle('active', el === row))
  }

  applyState(id, state) {
    current = { id: id == null ? null : id, state }
    this.render()
  }

  render() {
    this.trackTargets.forEach((el) => this.applyRowState(el, parseInt(el.dataset.trackId, 10)))
    // The playlist big player isn't a row of its own; it mirrors whichever track
    // the sidebar has marked active.
    if (!this.hasBigPlayTarget) return
    const active = this.trackTargets.find((el) => el.classList.contains('active'))
    const activeId = active ? parseInt(active.dataset.trackId, 10) : null
    this.bigPlayTargets.forEach((el) => this.applyRowState(el, activeId))
  }

  applyRowState(el, id) {
    const isCurrent = current.id != null && id === current.id
    el.classList.toggle('is-current', isCurrent)
    el.classList.toggle('is-playing', isCurrent && current.state === 'playing')
    el.classList.toggle('is-loading', isCurrent && current.state === 'loading')
  }

  descriptor(el) {
    const d = el.dataset
    return {
      id: parseInt(d.trackId, 10),
      url: d.trackUrl,
      title: d.trackTitle,
      artist: d.trackArtist,
      artistUrl: d.trackArtistUrl,
      trackUrl: d.trackPageUrl,
      imageUrl: d.trackImage,
      waveformUrl: d.trackWaveform,
      duration: d.trackDuration,
    }
  }
}
