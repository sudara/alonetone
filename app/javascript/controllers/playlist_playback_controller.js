import PlaybackController from './playback_controller'
import Rails from 'rails-ujs'

export default class extends PlaybackController {
  static targets = ['loadTrack']

  preInitialize() {
    this.url = this.playTarget.getAttribute('href') + '.mp3'
    this.permalink = this.playTarget.getAttribute('href').split('/').pop()
    this.preload = this.playTarget.parentElement.classList.contains('active')
  }

  seekBarContainerTarget() {
    this.bigPlay.seekBarContainerTarget
  }

  seekBarLoadedTarget() {
    this.bigPlay.seekBarLoadedTarget
  }

  // After PlaybackController#play is called, this stuff fires
  playCallback(e) {
    if (this.playTarget.getAttribute('href') === document.location.pathname) {
      // the bigPlay controller isn't yet linked
      if (!this.bigPlay) this.setBigPlay()
      if (this.loaded) this.bigPlay.animation.setPause()
      else this.bigPlay.animation.showLoading()
      this.highlightPlayingTrack()
    } else {
      // fire the ajax request
      Rails.fire(this.loadTrackTarget, 'click')
    }
    this.playTarget.classList.replace('play-button', 'pause-button')
    this.playTarget.firstElementChild.setAttribute('data-icon', 'pause')
  }

  pauseCallback() {
    this.bigPlay.animation.setPlay()
    this.playTarget.classList.replace('pause-button', 'play-button')
    this.playTarget.firstElementChild.setAttribute('data-icon', 'play')
  }

  // called by popstate@window so we don't interrupt playback with back/forward
  popTrack(e) {
    const newLocation = document.location.pathname.split('/').pop()
    if (newLocation === this.permalink) {
      Rails.fire(this.loadTrackTarget, 'click')
    }
  }

  highlightPlayingTrack() {
    // handle the "active" classes
    if (document.querySelector('.tracklist li.active')) {
      document.querySelector('.tracklist li.active').classList.remove('active')
    }
    this.element.classList.add('active')
  }

  // fires on ajax:success
  loadTrack(e) {
    this.highlightPlayingTrack()
    // show the cover
    document.querySelector('a.small-cover').style.display = 'block'

    // replace track content with result from ajax
    let temp = document.createElement('div')
    temp.innerHTML = e.detail[2].responseText
    document.querySelector('.track-content').replaceWith(temp.firstChild)
    if (e.target.href !== document.location.href) {
      const title = this.loadTrackTarget.textContent
      history.pushState(title, '', e.target.href)
    }

    // link this controller to the new big play button controller
    this.setBigPlay()
  }

  whilePlayingCallback() {
    if (!this.bigPlay) this.setBigPlay()
    if (!this.loaded) {
      this.bigPlay.animation.showPause()
      this.loaded = true
    }
    this.bigPlay.percentPlayed = this.percentPlayed()
    this.bigPlay.waveform.update()
    this.bigPlay.timeTarget.innerHTML = this.time
  }

  setBigPlay() {
    this.bigPlay = this.application.getControllerForElementAndIdentifier(document.querySelector('.track-content'), 'big-play')
  }
}
