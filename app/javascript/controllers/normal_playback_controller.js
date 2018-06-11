import PlaybackController from './playback_controller'
import PlayAnimation from '../animation/play_animation'

let currentlyOpen

export default class extends PlaybackController {
  // these are added to the targets defined in PlaybackController
  static targets = ['playButton', 'details', 'seekBarPlayed']

  preInitialize() {
    this.animation = new PlayAnimation()
    this.preload = false
  }
  postInitialize() {}

  whilePlayingCallback() {
    this.updateSeekBarPlayed()
  }

  playCallback() {
    this.openDetails()
    this.updateSeekBarLoaded()
  }

  toggleDetails(e) {
    e.preventDefault()
    const wasOpen = this.element.classList.contains('open')
    // if another track details is open, close it
    if (currentlyOpen) {
      currentlyOpen.element.classList.remove('open')
    }
    if (!wasOpen) {
      this.openDetails()
    }
  }

  openDetails() {
    if (currentlyOpen) {
      currentlyOpen.element.classList.remove('open')
    }
    currentlyOpen = this
    this.element.classList.add('open')
  }

  animateLoading() {
    this.playButtonTarget.style.display = 'none'
    this.playTarget.firstElementChild.append(document.getElementById('playAnimationSVG'))
    this.animation.init()
    this.animation.setPlay()
    this.animation.showLoading()
  }

  // With SoundManager we used to animate this width to display
  // how much of the track is downloaded
  // but it's no longer possible with Howl
  updateSeekBarLoaded() {
    this.seekBarContainerTarget.style.display = 'block'
    this.seekBarLoadedTarget.style.width = '100%'
  }
  updateSeekBarPlayed() {
    const position = this.sound.seek() / this.sound.duration()
    const maxwidth = this.seekBarLoadedTarget.offsetWidth
    this.seekBarPlayedTarget.style.width = `${position * maxwidth}px`
  }
}