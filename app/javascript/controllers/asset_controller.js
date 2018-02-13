import { Controller } from 'stimulus';

export default class extends Controller {
  // data-asset-playing="0" data-asset-opened="0">
  static targets = ['play', 'title', 'details']

  initialize() {
    this.isPlaying = false
  }

  togglePlay() {
    console.log(this.playTarget)
  }
  toggleDetails(e) {
    alert('wtf')
    e.preventDefault();
    if (this.element.classList.contains('open')) {
      this.element.classList.remove('open')
    } else {
      this.element.classList.add('open')
    }
  }
}
