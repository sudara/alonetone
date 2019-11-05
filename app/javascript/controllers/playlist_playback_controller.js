import Rails from '@rails/ujs'
import PlaybackController from './playback_controller'

const smallCover = document.querySelector('a.small_cover')
const sidebarLinks = document.querySelector('.sidebar_downloads')

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
      Rails.fire(this.loadTrackTarget, 'click')
    }
    this.registeredListen = false
    this.playTarget.classList.replace('play_button', 'pause_button')
    this.playTarget.firstElementChild.setAttribute('data-icon', 'pause')
  }

  pauseCallback() {
    this.bigPlay.pause()
    this.playTarget.classList.replace('pause_button', 'play_button')
    this.playTarget.firstElementChild.setAttribute('data-icon', 'play')
  }

  stopCallback() {
    this.bigPlay.stop()
  }

  // every instance of playlistPlayback listens for popstate@window
  // so that when forward/back is pressed, this method is called on each
  popTrack(e) {
    const newLocation = document.location.pathname.split('/').pop()
    // Only fire ajax for the track that actually matches the new location
    // Remember, every track in the playlist will run this code on popstate
    if (newLocation === this.permalink) {
      // console.log('should be ajax')
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
    document.querySelector('.track_content').replaceWith(temp.firstChild)
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
    this.bigPlay.update()
  }

  hideSmallCoverAndSidebarLinks() {
    document.querySelector('a.small_cover').style.display = 'none'
    document.querySelector('.sidebar_downloads').style.display = 'none'
  }

  showSmallCoverAndSidebarLinks() {
    document.querySelector('a.small_cover').style.display = 'block'
    document.querySelector('.sidebar_downloads').style.display = 'block'
    document.body.classList.remove('cover_view')
  }

  setBigPlay() {
    this.bigPlay = this.application.getControllerForElementAndIdentifier(document.querySelector('.track_content'), 'big-play')
  }

  isCurrentTrack() {
    return this.playTarget.getAttribute('href') === document.location.pathname
  }
}
