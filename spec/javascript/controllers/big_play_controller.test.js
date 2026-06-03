import { Application } from '@hotwired/stimulus'
import BigPlayController from 'controllers/big_play_controller'

const tick = () => new Promise((resolve) => setTimeout(resolve, 0))

const announce = (event, trackId) =>
  document.dispatchEvent(new CustomEvent(event, { detail: trackId == null ? {} : { track: { id: trackId } } }))

let application

const controller = () =>
  application.getControllerForElementAndIdentifier(document.querySelector('.track_post_play'), 'big-play')

const start = async (trackId = 1) => {
  document.body.innerHTML = `
    <div class="track_post_play" data-controller="big-play" data-big-play-track-id-value="${trackId}">
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
  application.register('big-play', BigPlayController)
  await tick()
}

afterEach(() => {
  if (application) application.stop()
  document.body.innerHTML = ''
})

describe('big-play#syncPlayButton', () => {
  it('drives loading then the play->pause morph for its own track', async () => {
    await start(1)
    const loading = jest.spyOn(controller().animation, 'loadingAnimation')
    const pausing = jest.spyOn(controller().animation, 'pausingAnimation')

    announce('player:loading', 1)
    announce('player:playing', 1)
    await tick()

    expect(loading).toHaveBeenCalled()
    expect(pausing).toHaveBeenCalled()
  })

  it('snaps to the pause icon when resuming after the first play', async () => {
    await start(1)
    announce('player:playing', 1)
    const showPause = jest.spyOn(controller().animation, 'showPauseButton')

    announce('player:paused', 1)
    announce('player:playing', 1)
    await tick()

    expect(showPause).toHaveBeenCalled()
  })

  it('returns to the play icon for an event about a different track', async () => {
    await start(1)
    const showPlay = jest.spyOn(controller().animation, 'showPlayButton')

    announce('player:playing', 2)
    await tick()

    expect(showPlay).toHaveBeenCalled()
  })

  it('returns to the play icon when the queue ends', async () => {
    await start(1)
    announce('player:playing', 1)
    const showPlay = jest.spyOn(controller().animation, 'showPlayButton')

    announce('player:queueended')
    await tick()

    expect(showPlay).toHaveBeenCalled()
  })
})
