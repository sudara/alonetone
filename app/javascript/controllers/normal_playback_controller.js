import PlaybackController from './playback_controller'
import PlayAnimation from '../animation/play_animation'

let currentlyOpen

export default class extends PlaybackController {
  // these are added to the targets defined in PlaybackController
  static targets = ['playButton', 'details', 'time', 'seekBarPlayed', 'title']

  preInitialize() {
    this.preload = false
    this.alreadyPlayed = false
    this.url = this.playTarget.querySelector('a').getAttribute('href')
  }

  whilePlayingCallback() {
    if (!this.loaded) {
      this.animation.showPause()
      this.loaded = true
    }
    this.updateSeekBarPlayed()
    this.timeTarget.innerHTML = this.time
  }

  playCallback() {
    this.showAnimation()
    this.openDetails()
    this.updateSeekBarLoaded()
    this.registeredListen = true
    this.alreadyPlayed = true
  }

  pauseCallback() {
    this.animation.setPlay()
  }

  stopCallback() {
    this.animation.setPlay()
  }

  toggleDetails(e) {
    if (!e.target.classList.contains('artist')) {
      // if the link in the track top is the artist link, go to that URL,
      // otherwise open the track reveal section
      e.preventDefault()

      const wasOpen = this.element.classList.contains('open')
      // if another track details is open, close it
      if (currentlyOpen) {
        currentlyOpen.closeDetails()
      }
      if (!wasOpen && !this.data.get('openable')) {
        this.openDetails()
      }
    }
  }

  closeDetails() {
    // Height of the details could have changed (for example private banner showing)
    // So let's recalculate the offset for animating
    this.detailsTarget.style.marginTop = `-${this.detailsTarget.offsetHeight}px`
    this.element.classList.remove('open')
    this.seekBarContainerTarget.classList.remove('show')
  }

  openDetails() {
    if (currentlyOpen) {
      currentlyOpen.element.classList.remove('open')
    }
    currentlyOpen = this
    this.detailsTarget.style.display = 'block'
    this.detailsTarget.style.marginTop = `-${this.detailsTarget.offsetHeight}px`
    this.element.classList.add('open')
    if (this.alreadyPlayed) {
      this.seekBarContainerTarget.classList.add('show')
    }
  }

  showAnimation() {
    this.cloneAnimationIfNeeded()
    if (!this.loaded) {
      this.playButtonTarget.style.display = 'none' // hide the dummy play button
      this.animateLoading()
    } else this.animation.setPause()
  }

  // Print our own copy of #playAnimationSVG to animate freely as we like
  // Until this point, the play button has been a placeholder icon SVG
  // After this point, the play button is an animatable SVG
  cloneAnimationIfNeeded() {
    if (this.animation === undefined) {
      const animationElement = document.getElementById('playAnimationSVG').cloneNode(true);
      animationElement.id = this.data.get('id')
      this.playTarget.firstElementChild.append(animationElement)
      this.animation = new PlayAnimation(animationElement)
    }
  }

  animateLoading() {
    this.animation.init()
    this.animation.setPlay()
    this.animation.showLoading()
  }

  // With SoundManager we used to animate this width to display
  // how much of the track is downloaded
  // but it's no longer possible with Howl
  updateSeekBarLoaded() {
    this.seekBarContainerTarget.classList.add('show');
    this.seekBarLoadedTarget.style.width = '100%'
  }

  updateSeekBarPlayed() {
    const position = this.position / this.sound.duration()
    const maxwidth = this.seekBarLoadedTarget.offsetWidth
    this.seekBarPlayedTarget.style.width = `${position * maxwidth}px`
  }

  seek(e) {
    const offset = e.clientX - this.seekBarContainerTarget.getBoundingClientRect().left
    const newPosition = offset / this.seekBarContainerTarget.offsetWidth
    super.seek(newPosition)
  }

  skim(e) {
    const offx = e.clientX - this.seekBarContainerTarget.getBoundingClientRect().left
    this.seekBarLoadedTarget.style.left = `${offx}px`
  }

  // turbolinks will cache this page, so here's our chance to reset things to normal
  disconnect() {
    if (this.sound.playing()) {
      this.sound.pause()
    }
    if (this.element.classList.contains('open')) {
      this.element.classList.remove('open')
    }
  }
}
