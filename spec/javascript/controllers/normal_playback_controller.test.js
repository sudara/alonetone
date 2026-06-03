import { Application } from '@hotwired/stimulus'
import NormalPlaybackController from 'controllers/normal_playback_controller'

const tick = () => new Promise((resolve) => setTimeout(resolve, 0))

const row = (id) => `
  <div class="asset" data-controller="normal-playback" data-track-id="${id}">
    <a class="play_link"><svg class="playIconSymbol"></svg></a>
    <div class="tracks_reveal" data-normal-playback-target="details"></div>
  </div>`

const announce = (event, id) =>
  document.dispatchEvent(new CustomEvent(event, { detail: id == null ? {} : { track: { id } } }))

let application

const controllerFor = (id) =>
  application.getControllerForElementAndIdentifier(
    document.querySelector(`[data-track-id="${id}"]`), 'normal-playback'
  )

const start = async (html) => {
  document.body.innerHTML = html
  application = Application.start()
  application.register('normal-playback', NormalPlaybackController)
  await tick()
}

afterEach(async () => {
  if (application) application.stop()
  document.body.innerHTML = ''
})

describe('normal-playback#syncPlayButton', () => {
  it('resets the row when the queue ends even though the event still carries the last track', async () => {
    await start(row(1))
    const controller = controllerFor(1)
    const reset = jest.spyOn(controller, 'resetAnimation')
    const toState = jest.spyOn(controller, 'toAnimState')

    announce('player:queueended', 1)
    await tick()

    expect(reset).toHaveBeenCalled()
    expect(toState).not.toHaveBeenCalledWith('loading')
  })

  it('drives loading then playing then paused for its own track', async () => {
    await start(row(1))
    const controller = controllerFor(1)
    const toState = jest.spyOn(controller, 'toAnimState')

    announce('player:loading', 1)
    announce('player:playing', 1)
    announce('player:paused', 1)
    await tick()

    expect(toState.mock.calls.map((c) => c[0])).toEqual(['loading', 'playing', 'paused'])
  })

  it('resets when an event targets a different row', async () => {
    await start(row(1))
    const controller = controllerFor(1)
    const reset = jest.spyOn(controller, 'resetAnimation')

    announce('player:playing', 2)
    await tick()

    expect(reset).toHaveBeenCalled()
  })
})
