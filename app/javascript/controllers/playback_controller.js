import { Controller } from 'stimulus'
import Rails from '@rails/ujs'

// All variants of alonetone's javascript players extends this controller
export default class extends Controller {
  static targets = ['title', 'seekBarContainer', 'seekBarLoaded']

  initialize() {
    this.preInitialize()
  }

  disconnect() {
    //this.sound.pause()
  }

  play(e) {
    this.isPlaying = true
    this.element.classList.add('playing')
    this.playCallback(e)
  }

  pause() {
    this.isPlaying = false
    this.pauseCallback()
  }

  stop() {
    this.stopCallback()
  }

  registerListen() {
    Rails.ajax({
      url: '/listens',
      type: 'POST',
      data: `id=${this.data.get('id')}`,
      success() {
      },
    })
  }

}
