import { Controller } from '@hotwired/stimulus'

// Wraps a collection of track rows (e.g. a home page "box" or a playlist
// sidebar). On play it builds a queue from its rows in DOM order and hands it to
// the persistent #player. Playing a row in a different collection rebuilds the
// queue from scratch, so the queue always reflects the last collection the
// listener touched.
export default class extends Controller {
  static targets = ['track']

  play(event) {
    event.preventDefault()
    const row = event.target.closest('[data-tracklist-target="track"]')
    if (row) this.playRow(row)
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
  }

  // The big player's play button isn't itself a row; play whichever track the
  // page has marked active (the one shown in the detail frame), else the first.
  playActive(event) {
    if (event) event.preventDefault()
    const row = this.trackTargets.find((el) => el.classList.contains('active')) || this.trackTargets[0]
    if (row) this.playRow(row)
  }

  playRow(row) {
    this.markActive(row)
    const startIndex = this.trackTargets.indexOf(row)
    const queue = this.trackTargets.map((el) => this.descriptor(el))
    this.dispatch('play', { target: window, detail: { queue, startIndex } })
  }

  markActive(row) {
    this.trackTargets.forEach((el) => el.classList.toggle('active', el === row))
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
