import Rails from '@rails/ujs'
import PlaybackController from './playback_controller'

const smallCover = document.querySelector('a.small_cover')
const sidebarLinks = document.querySelector('.sidebar_downloads')

export default class extends PlaybackController {
  static targets = ['play', 'loadTrack']

  initialize() {
    this.permalink = this.playTarget.getAttribute('href').split('/').pop()
    this.duration = 0.0
    this.currentTime = 0.0
    this.percentPlayed = 0
  }

  fireClick() {
    Rails.fire(this.playTarget, 'click')
  }

  // After PlaybackController#play is called, this stuff fires
  playCallback(e) {
    if (this.isCurrentTrack()) {
      this.setBigPlay()
    } else {
      this.bigPlayLoaded = false
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
    this.playTarget.classList.replace('pause_button', 'play_button')
    this.playTarget.firstElementChild.setAttribute('data-icon', 'play')
    this.bigPlay.stop()
  }

  playing(event) {
    this.duration = event.detail.duration
    this.currentTime = event.detail.currentTime
    this.percentPlayed = event.detail.percentPlayed
    this.bigPlay.update(event.detail.duration, event.detail.currentTime, event.detail.percentPlayed)
    this.bigPlay.play()
  }

  whilePlaying(event) {
    this.duration = event.detail.duration
    this.currentTime = event.detail.currentTime
    this.percentPlayed = event.detail.percentPlayed
    if (this.bigPlayLoaded) {
      this.bigPlay.update(event.detail.duration, event.detail.currentTime, event.detail.percentPlayed)
    }
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

  hideSmallCoverAndSidebarLinks() {
    document.querySelector('a.small_cover').style.display = 'none'
    document.querySelector('.sidebar_downloads').style.display = 'none'
  }

  showSmallCoverAndSidebarLinks() {
    document.querySelector('a.small_cover').style.display = 'block'
    document.querySelector('.sidebar_downloads').style.display = 'block'
    document.body.classList.remove('cover_view')
  }

  async setBigPlay() {
    this.bigPlay = null // reset
    while (this.bigPlay === null) {
      this.bigPlay = this.application.getControllerForElementAndIdentifier(document.querySelector('.track_content'), 'big-play')

      // eslint-disable-next-line no-await-in-loop
      await new Promise((resolve) => setTimeout(resolve, 20))
    }
    this.bigPlayLoaded = true
    this.bigPlay.update(this.duration, this.currentTime, this.percentPlayed)
    this.bigPlay.setAnimationState(this.isPlaying)
  }

  // hacky way to determine if we need to load in a new track or not
  isCurrentTrack() {
    return this.playTarget.getAttribute('href').replace('.mp3', '') === document.location.pathname
  }

  disconnect() {
    super.disconnect()
  }
}
