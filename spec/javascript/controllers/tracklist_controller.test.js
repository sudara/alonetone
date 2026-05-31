import { Application } from '@hotwired/stimulus'
import TracklistController from 'controllers/tracklist_controller'

const tick = () => new Promise((resolve) => setTimeout(resolve, 0))

const row = (id) => `
  <div class="asset" data-tracklist-target="track"
       data-track-id="${id}"
       data-track-url="/u/track-${id}.mp3"
       data-track-page-url="/u/track-${id}"
       data-track-title="Track ${id}"
       data-track-artist="Artist"
       data-track-waveform="/u/track-${id}/waveform">
    <a class="play_link" href="/u/track-${id}.mp3" data-action="click->tracklist#play">play</a>
  </div>`

// Drives the module-level `current` state the same way the live player does.
const announce = (event, id) =>
  document.dispatchEvent(new CustomEvent(event, { detail: { track: { id } } }))

let application

const start = async (html) => {
  document.body.innerHTML = html
  application = Application.start()
  application.register('tracklist', TracklistController)
  await tick()
}

afterEach(async () => {
  // queueended resets the shared `current` to null so tests don't leak state
  document.dispatchEvent(new CustomEvent('player:queueended', { detail: {} }))
  await tick()
  if (application) application.stop()
  document.body.innerHTML = ''
})

describe('tracklist#play', () => {
  it('rebuilds the queue and starts playback for a row that is not current', async () => {
    await start(`<div data-controller="tracklist">${row(1)}${row(2)}</div>`)
    const played = []
    window.addEventListener('tracklist:play', (e) => played.push(e.detail))

    document.querySelectorAll('.play_link')[1].click()
    await tick()

    expect(played).toHaveLength(1)
    expect(played[0].startIndex).toBe(1)
    expect(played[0].queue.map((t) => t.id)).toEqual([1, 2])
  })

  it('toggles the persistent player instead of restarting the current row', async () => {
    await start(`<div data-controller="tracklist">${row(1)}${row(2)}</div>`)
    const played = []
    const toggled = []
    window.addEventListener('tracklist:play', (e) => played.push(e.detail))
    window.addEventListener('tracklist:toggle', () => toggled.push(true))

    announce('player:playing', 1)
    await tick()
    document.querySelectorAll('.play_link')[0].click()
    await tick()

    expect(toggled).toHaveLength(1)
    expect(played).toHaveLength(0)
  })
})

describe('state mirroring', () => {
  it('marks the current row playing and leaves the others alone', async () => {
    await start(`<div data-controller="tracklist">${row(1)}${row(2)}</div>`)

    announce('player:playing', 2)
    await tick()

    const [first, second] = document.querySelectorAll('[data-tracklist-target="track"]')
    expect(second.classList.contains('is-current')).toBe(true)
    expect(second.classList.contains('is-playing')).toBe(true)
    expect(first.classList.contains('is-current')).toBe(false)
  })

  it('reflects loading then playing then paused for the current row', async () => {
    await start(`<div data-controller="tracklist">${row(1)}</div>`)
    const track = document.querySelector('[data-tracklist-target="track"]')

    announce('player:loading', 1)
    await tick()
    expect(track.classList.contains('is-loading')).toBe(true)

    announce('player:playing', 1)
    await tick()
    expect(track.classList.contains('is-loading')).toBe(false)
    expect(track.classList.contains('is-playing')).toBe(true)

    announce('player:paused', 1)
    await tick()
    expect(track.classList.contains('is-playing')).toBe(false)
    expect(track.classList.contains('is-current')).toBe(true)
  })
})

describe('switching the playlist detail frame', () => {
  it('points the playlist-track frame at the played row', async () => {
    await start(`
      <div id="playlist-track"></div>
      <div data-controller="tracklist">${row(1)}${row(2)}</div>`)

    document.querySelectorAll('.play_link')[1].click()
    await tick()

    expect(document.getElementById('playlist-track').getAttribute('src')).toBe('/u/track-2')
  })

  it('leaves the frame untouched when re-playing the row it already shows', async () => {
    await start(`
      <div id="playlist-track" src="/u/track-1"></div>
      <div data-controller="tracklist">${row(1)}</div>`)

    document.querySelector('.play_link').click()
    await tick()

    expect(document.getElementById('playlist-track').getAttribute('src')).toBe('/u/track-1')
  })
})

describe('big player mirroring', () => {
  it('reflects the active row state onto the bigPlay target', async () => {
    await start(`
      <div data-controller="tracklist">
        <div data-tracklist-target="bigPlay"></div>
        ${row(1)}
        <div class="asset active" data-tracklist-target="track" data-track-id="2"></div>
      </div>`)

    announce('player:playing', 2)
    await tick()

    const bigPlay = document.querySelector('[data-tracklist-target="bigPlay"]')
    expect(bigPlay.classList.contains('is-current')).toBe(true)
    expect(bigPlay.classList.contains('is-playing')).toBe(true)
  })
})

describe('tracklist#playActive', () => {
  it('plays the active row when the big player button is pressed', async () => {
    await start(`
      <div data-controller="tracklist">
        <button class="big" data-action="click->tracklist#playActive">play</button>
        ${row(1)}
        <div class="asset active" data-tracklist-target="track"
             data-track-id="2" data-track-url="/u/track-2.mp3" data-track-page-url="/u/track-2"></div>
      </div>`)
    const played = []
    window.addEventListener('tracklist:play', (e) => played.push(e.detail))

    document.querySelector('.big').click()
    await tick()

    expect(played).toHaveLength(1)
    expect(played[0].startIndex).toBe(1)
  })

  it('falls back to the first row when none is marked active', async () => {
    await start(`
      <div data-controller="tracklist">
        <button class="big" data-action="click->tracklist#playActive">play</button>
        ${row(1)}${row(2)}
      </div>`)
    const played = []
    window.addEventListener('tracklist:play', (e) => played.push(e.detail))

    document.querySelector('.big').click()
    await tick()

    expect(played[0].startIndex).toBe(0)
  })

  it('toggles instead of restarting when the active track is already current', async () => {
    await start(`
      <div data-controller="tracklist">
        <button class="big" data-action="click->tracklist#playActive">play</button>
        <div class="asset active" data-tracklist-target="track"
             data-track-id="5" data-track-page-url="/u/track-5"></div>
      </div>`)
    const played = []
    const toggled = []
    window.addEventListener('tracklist:play', (e) => played.push(e.detail))
    window.addEventListener('tracklist:toggle', () => toggled.push(true))

    announce('player:playing', 5)
    await tick()
    document.querySelector('.big').click()
    await tick()

    expect(toggled).toHaveLength(1)
    expect(played).toHaveLength(0)
  })

  it('does not reload an eager-loaded frame when starting the already-active row', async () => {
    await start(`
      <div id="playlist-track"></div>
      <div data-controller="tracklist">
        <button class="big" data-action="click->tracklist#playActive">play</button>
        <div class="asset active" data-tracklist-target="track"
             data-track-id="5" data-track-page-url="/u/track-5"></div>
      </div>`)

    document.querySelector('.big').click()
    await tick()

    expect(document.getElementById('playlist-track').getAttribute('src')).toBeNull()
  })
})

describe('following auto-advance', () => {
  it('moves the active row and detail frame to the auto-advanced track', async () => {
    await start(`
      <div id="playlist-track" src="/u/track-1"></div>
      <div data-controller="tracklist">
        <div class="asset active" data-tracklist-target="track"
             data-track-id="1" data-track-page-url="/u/track-1"></div>
        ${row(2)}
      </div>`)

    // stitches advances to the next track with no click
    announce('player:trackchanged', 2)
    await tick()

    const [first, second] = document.querySelectorAll('[data-tracklist-target="track"]')
    expect(second.classList.contains('active')).toBe(true)
    expect(first.classList.contains('active')).toBe(false)
    expect(document.getElementById('playlist-track').getAttribute('src')).toBe('/u/track-2')
  })
})

describe('syncActiveFromFrame', () => {
  it('marks the row whose page url matches the loaded frame as active', async () => {
    await start(`
      <div data-controller="tracklist"
           data-action="turbo:frame-load->tracklist#syncActiveFromFrame">
        ${row(1)}${row(2)}
      </div>`)

    const frame = document.createElement('div')
    frame.id = 'playlist-track'
    frame.setAttribute('src', '/u/track-2')
    document.querySelector('[data-controller="tracklist"]').appendChild(frame)
    frame.dispatchEvent(new CustomEvent('turbo:frame-load', { bubbles: true }))
    await tick()

    const [first, second] = document.querySelectorAll('[data-tracklist-target="track"]')
    expect(second.classList.contains('active')).toBe(true)
    expect(first.classList.contains('active')).toBe(false)
  })
})

describe('two collections sharing the player state', () => {
  it('mirrors the playing track across independent tracklists on the page', async () => {
    await start(`
      <div class="box-a" data-controller="tracklist">${row(1)}${row(2)}</div>
      <div class="box-b" data-controller="tracklist">${row(2)}${row(3)}</div>`)

    announce('player:playing', 2)
    await tick()

    const playing = [...document.querySelectorAll('[data-track-id="2"]')]
    expect(playing).toHaveLength(2)
    playing.forEach((el) => expect(el.classList.contains('is-playing')).toBe(true))
    expect(document.querySelector('[data-track-id="3"]').classList.contains('is-playing')).toBe(false)
  })
})
