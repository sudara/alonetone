import { Controller } from 'stimulus'
import Rails from '@rails/ujs'

// All variants of alonetone's javascript players extends this controller
export default class extends Controller {
  static targets = ['play', 'title', 'seekBarContainer', 'seekBarLoaded']

  initialize() {
    this.preInitialize()
  }

  disconnect() {
    //this.sound.pause()
  }

  // Called once by the howler onplay/onseek callbacks
  // and recurses to give us a way to update throughout playback
  whilePlaying() {
    if (this.sound.playing()) {
      this.whilePlayingCallback()
    }
  }

  // called immedately by js
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

  togglePlay(e) {
    if (this.isPlaying) {
      this.pause()
    } else {
      this.play()
    }
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
