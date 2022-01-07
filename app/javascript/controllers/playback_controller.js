import { Controller } from "@hotwired/stimulus"

// All variants of alonetone's javascript players extends this controller
export default class extends Controller {
  static targets = ['title', 'seekBarContainer', 'seekBarLoaded']

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
    // console.log("REGIIIISTERRRRRRRING")
    // Rails.ajax({
    //   url: '/listens',
    //   type: 'POST',
    //   data: `id=${this.data.get('id')}`,
    //   success() {
    //   },
    // })
  }
}
