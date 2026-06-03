import { Application } from '@hotwired/stimulus'
import PlayerController from 'controllers/player_controller'

const tick = () => new Promise((resolve) => setTimeout(resolve, 0))

const announce = (event, detail = {}) =>
  document.dispatchEvent(new CustomEvent(event, { detail }))

// the first timeupdate is what reports the real track length
const announceTimeUpdate = (duration) =>
  announce('player:timeupdate', { percent: 0.01, currentTimeFormatted: '0:01', duration })

let application

const controller = () =>
  application.getControllerForElementAndIdentifier(document.querySelector('#player'), 'player')

const loadedWidth = () =>
  parseFloat(document.querySelector('[data-player-target="loadedReveal"]').getAttribute('width'))

const start = async () => {
  document.body.innerHTML = `
    <div id="player" data-controller="player"
         data-action="
           player:playing@document->player#playing
           player:whileloading@document->player#whileLoading
           player:timeupdate@document->player#timeUpdate
           player:paused@document->player#paused
           player:ended@document->player#ended
           player:error@document->player#error
           player:trackchanged@document->player#trackChanged
           player:seeked@document->player#seeked">
      <a data-player-target="title"></a>
      <a data-player-target="artist"></a>
      <div data-player-target="waveform"></div>
      <div data-player-target="seekBar"></div>
      <div data-player-target="progress"></div>
      <span data-player-target="time"></span>
      <svg><polygon data-player-target="waveformPoints"/><rect data-player-target="waveformReveal" x="-500"/><rect data-player-target="loadedReveal" width="0"/></svg>
      <svg class="largePlaySVG">
        <circle class="outline"/>
        <circle class="dotty"/>
        <circle class="centerCircle"/>
        <path class="icon"/>
        <g class="pauseContainer"><g class="pauseLoopGroup"></g></g>
        <g class="pauseGroup"><line/><line/></g>
      </svg>
    </div>`
  application = Application.start()
  application.register('player', PlayerController)
  await tick()
}

afterEach(() => {
  if (application) application.stop()
  document.body.innerHTML = ''
})

describe('player#startPlayhead', () => {
  it('does not start the playhead until the real duration is known', async () => {
    await start()
    const play = jest.spyOn(controller().timeline, 'play')

    announce('player:playing')
    await tick()
    expect(play).not.toHaveBeenCalled()

    announceTimeUpdate(42.6)
    await tick()
    expect(play).toHaveBeenCalled()
  })

  it('starts the playhead immediately when the track change seeds a known duration', async () => {
    await start()
    announce('player:trackchanged', { track: { duration: '180' } })
    const play = jest.spyOn(controller().timeline, 'play')

    announce('player:playing')
    await tick()

    expect(play).toHaveBeenCalled()
    expect(controller().timeline.timeScale()).toBeCloseTo(1 / 180)
  })

  it('does not seed a duration from a blank track length', async () => {
    await start()
    announce('player:trackchanged', { track: { duration: '' } })
    const play = jest.spyOn(controller().timeline, 'play')

    announce('player:playing')
    await tick()

    expect(play).not.toHaveBeenCalled()
  })

  it('falls back to the first timeupdate when the track has no stored duration', async () => {
    await start()
    announce('player:trackchanged', { track: {} })
    const play = jest.spyOn(controller().timeline, 'play')

    announce('player:playing')
    await tick()
    expect(play).not.toHaveBeenCalled()

    announceTimeUpdate(42.6)
    await tick()
    expect(play).toHaveBeenCalled()
  })

  it('starts the playhead for a track whose duration is exactly the placeholder length', async () => {
    await start()
    const play = jest.spyOn(controller().timeline, 'play')

    announce('player:playing')
    announceTimeUpdate(1)
    await tick()

    expect(play).toHaveBeenCalled()
  })

  it('holds the next track at zero until its own duration lands', async () => {
    await start()
    announce('player:playing')
    announceTimeUpdate(42.6)
    announce('player:trackchanged', { track: {} })
    const play = jest.spyOn(controller().timeline, 'play')

    announce('player:playing')
    await tick()
    expect(play).not.toHaveBeenCalled()

    announceTimeUpdate(60)
    await tick()
    expect(play).toHaveBeenCalled()
  })
})

describe('player#seeked', () => {
  it('does not resume the playhead animation when seeking while paused', async () => {
    await start()
    announce('player:playing')
    announceTimeUpdate(42.6)
    announce('player:paused')
    const play = jest.spyOn(controller().timeline, 'play')

    announce('player:seeked')
    await tick()

    expect(play).not.toHaveBeenCalled()
  })

  it('resumes the playhead animation when seeking while playing', async () => {
    await start()
    announce('player:playing')
    announceTimeUpdate(42.6)
    const play = jest.spyOn(controller().timeline, 'play')

    announce('player:seeked')
    await tick()

    expect(play).toHaveBeenCalled()
  })

  it('does not resume the playhead after the track has ended', async () => {
    await start()
    announce('player:playing')
    announceTimeUpdate(42.6)
    announce('player:ended')
    const play = jest.spyOn(controller().timeline, 'play')

    announce('player:seeked')
    await tick()

    expect(play).not.toHaveBeenCalled()
  })

  it('does not resume the playhead after a playback error', async () => {
    await start()
    announce('player:playing')
    announceTimeUpdate(42.6)
    announce('player:error')
    const play = jest.spyOn(controller().timeline, 'play')

    announce('player:seeked')
    await tick()

    expect(play).not.toHaveBeenCalled()
  })
})

describe('player#whileLoading', () => {
  const changeTrack = (duration) => announce('player:trackchanged', { track: { duration } })
  const announceLoading = (secondsLoaded, duration) =>
    announce('player:whileloading', { secondsLoaded, duration })

  it('fills the loaded layer from buffered seconds over the DB duration', async () => {
    await start()
    changeTrack('180')

    announceLoading(90)
    await tick()

    expect(loadedWidth()).toBeCloseTo(250) // 90/180 * 500
  })

  it('divides by the DB duration rather than the media element duration', async () => {
    await start()
    changeTrack('180')

    announceLoading(90, 45) // the unreliable media duration during loading
    await tick()

    expect(loadedWidth()).toBeCloseTo(250) // still 90/180, not 90/45
  })

  it('falls back to the event duration when the track has no stored length', async () => {
    await start()
    changeTrack(undefined)

    announceLoading(30, 60)
    await tick()

    expect(loadedWidth()).toBeCloseTo(250) // 30/60 * 500
  })

  it('clamps the fill to the full width when more is buffered than the duration', async () => {
    await start()
    changeTrack('180')

    announceLoading(9999)
    await tick()

    expect(loadedWidth()).toBe(500)
  })

  it('ignores loading progress when there is no loaded layer to fill', async () => {
    await start()
    document.querySelector('[data-player-target="loadedReveal"]').remove()
    changeTrack('180')

    expect(() => {
      announceLoading(90)
    }).not.toThrow()
  })

  it('keeps the buffered fill through a pause; only a track change clears it', async () => {
    await start()
    changeTrack('180')
    announceLoading(90)
    await tick()
    expect(loadedWidth()).toBeCloseTo(250)

    announce('player:paused')
    await tick()

    expect(loadedWidth()).toBeCloseTo(250)
  })

  it('resets the loaded fill when the track changes', async () => {
    await start()
    changeTrack('180')
    announceLoading(90)
    await tick()
    expect(loadedWidth()).toBeCloseTo(250)

    changeTrack('200')
    await tick()

    expect(loadedWidth()).toBe(0)
  })
})

describe('player#timeUpdate', () => {
  const timeText = () =>
    document.querySelector('[data-player-target="time"]').textContent
  const changeTrack = (duration) => announce('player:trackchanged', { track: { duration } })

  it('shows the total track length while a freshly changed track is loading', async () => {
    await start()
    changeTrack('225')
    await tick()
    expect(timeText()).toBe('3:45')
  })

  it('holds the total length through timeupdates until playback actually starts', async () => {
    await start()
    changeTrack('225')
    announceTimeUpdate(225) // a loading timeupdate before play
    await tick()
    expect(timeText()).toBe('3:45')
  })

  it('counts up from the current time once playing', async () => {
    await start()
    changeTrack('225')
    announce('player:playing')
    announceTimeUpdate(225)
    await tick()
    expect(timeText()).toBe('0:01')
  })

  it('falls back to 0:00 when a changed track has no known length', async () => {
    await start()
    changeTrack('')
    await tick()
    expect(timeText()).toBe('0:00')
  })
})
