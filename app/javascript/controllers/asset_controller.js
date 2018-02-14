import { Controller } from 'stimulus';
import { playAnimation } from '../animation/play_animation'

let player
let currentlyOpen
const animation = new PlayAnimation();

export default class extends Controller {
  // data-asset-playing="0" data-asset-opened="0">
  static targets = ['play', 'playButton', 'title', 'details']

  initialize() {
    this.isPlaying = false
  }

  disconnect() {
    this.pause()
  }

  play() {
    if (player) {
      player.pause()
    }
    player = this
    this.isPlaying = true
    this.animateLoading()
  }

  pause() {
    player = null
    this.isPlaying = false
  }

  togglePlay(e) {
    e.preventDefault()
    if (this.isPlaying) {
      this.pause()
    } else {
      this.play()
    }
  }

  animateLoading() {
    this.playButtonTarget.style.display = 'none'
    this.playTarget.firstElementChild.append(document.getElementById('playAnimationSVG'))
    animation.init()
    animation.setPlay()
    animation.showLoading()
  }

  toggleDetails(e) {
    e.preventDefault()
    const wasOpen = this.element.classList.contains('open')
    // if another track details is open, close it
    if (currentlyOpen) {
      currentlyOpen.element.classList.remove('open')
    }
    if (!wasOpen) {
      currentlyOpen = this
      this.element.classList.add('open')
    }
  }
}
