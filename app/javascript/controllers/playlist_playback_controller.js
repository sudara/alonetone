import Rails from '@rails/ujs'
import PlaybackController from './playback_controller'

const smallCover = document.querySelector('a.small-cover')
const sidebarLinks = document.querySelector('.sidebar-downloads')

export default class extends PlaybackController {
  static targets = ['loadTrack']

  preInitialize() {
    this.url = `${this.playTarget.getAttribute('href')}.mp3`
    this.permalink = this.playTarget.getAttribute('href').split('/').pop()
    this.preload = this.playTarget.parentElement.classList.contains('active')
  }

  // After PlaybackController#play is called, this stuff fires
  playCallback(e) {
    if (this.isCurrentTrack()) {
      // the bigPlay controller isn't yet linked
      if (!this.bigPlay) this.setBigPlay()
      this.bigPlay.setAnimationState()
      this.highlightPlayingTrack()
    } else {
      this.fireAjaxRequest()
    }
    this.registeredListen = false
    this.playTarget.classList.replace('play-button', 'pause-button')
    this.playTarget.firstElementChild.setAttribute('data-icon', 'pause')
  }

  pauseCallback() {
    this.bigPlay.animation.setPlay()
    this.playTarget.classList.replace('pause-button', 'play-button')
    this.playTarget.firstElementChild.setAttribute('data-icon', 'play')
  }

  stopCallback() {
    this.bigPlay.reset()
  }

  // every instance of playlistPlayback listens for popstate@window
  // so that when forward/back is pressed, this method is called on each
  popTrack(e) {
    const newLocation = document.location.pathname.split('/').pop()
    // Only fire ajax for the track that actually matches the new location
    // Remember, every track in the playlist will run this code on popstate
    if (newLocation === this.permalink) {
      console.log('should be ajax')
      Rails.fire(this.loadTrackTarget, 'click')
      e.stopImmediatePropagation()
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
    this.showSmallCoverAndSidebarLinks()

    // replace track content with result from ajax
    const temp = document.createElement('div')
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
      this.loaded = true
      this.bigPlay.play()
    }
    this.bigPlay.update(this.percentPlayed())
  }

  hideSmallCoverAndSidebarLinks() {
    document.querySelector('a.small-cover').style.display = 'none'
    document.querySelector('.sidebar-downloads').style.display = 'none'
  }

  showSmallCoverAndSidebarLinks() {
    document.querySelector('a.small-cover').style.display = 'block'
    document.querySelector('.sidebar-downloads').style.display = 'block'
    document.body.classList.remove('cover-view')
  }

  setBigPlay() {
    this.bigPlay = this.application.getControllerForElementAndIdentifier(document.querySelector('.track-content'), 'big-play')
  }

  isCurrentTrack() {
    return this.playTarget.getAttribute('href') === document.location.pathname
  }

  // This workaround necessary until https://github.com/rails/rails/pull/36437 is merged
  // At which point we can just use Rails.fire inline
  fireAjaxRequest() {
    const event = new MouseEvent('click', {
      bubbles: true,
      cancelable: true,
      button: 0,
    })
    this.loadTrackTarget.dispatchEvent(event)
  }
}
