import PlaybackController from './playback_controller'

const smallCover = document.querySelector('a.small_cover')
const sidebarLinks = document.querySelector('.sidebar_downloads')

// This is a controller for ONE mp3, one <li>
export default class extends PlaybackController {
  static targets = ['play', 'loadTrack']

  initialize() {
    this.permalink = this.playTarget.getAttribute('href').split('/').pop()
    this.duration = 0.0
    this.currentTime = '0:00'
    this.percentPlayed = 0.0
    this.bigPlay = null
  }

  // called from bigPlay
  fireClick() {
	  console.log('fireClick called from bigplay');
    this.playTarget.click()
  }

  // calls to bigPlay
  seeked() {
    this.bigPlay.seeked()
  }

  // After PlaybackController#play is called, this stuff fires
  playCallback(e) {
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

  whileLoading(event) {
    this.duration = event.detail.duration
		if (this.bigPlayLoaded) {
    	this.bigPlay.load(this.duration)
		}
  }

  // this is essentially the first "whilePlaying" call
  async playing(event) {
    while (this.bigPlay === null) {
      // eslint-disable-next-line no-await-in-loop
      await new Promise((resolve) => setTimeout(resolve, 20))
    }
    this.bigPlay.update(event.detail.duration, event.detail.currentTime, event.detail.percentPlayed)
    this.bigPlay.play()
  }

  whilePlaying(event) {
    this.duration = event.detail.duration
    this.currentTime = event.detail.currentTime
    this.percentPlayed = event.detail.percentPlayed
    this.bigPlay.update(event.detail.duration, event.detail.currentTime, event.detail.percentPlayed)
  }
  
	// we can't "promote" our frame loads to visits
	// via data-turbo-action="advance"
	// because we reset the player on turbo:load
	// this is just a hack to get history working 
	// every instance of playlistPlayback listens for popstate@window
  // so that when forward/back is pressed, this method is called on each
	// the only thing this is used for 
	// is making sure the correct track in the playlist is highlighted
  popTrack(e) {
    const newLocation = document.location.pathname.split('/').pop()
    // Only fire ajax for the track that actually matches the new location
    // Remember, every track in the playlist will run this code on popstate
    if (newLocation === this.permalink.split('.').shift()) {
      // console.log('should be ajax')
      this.loadTrackTarget.click()
      e.stopImmediatePropagation()
    }
  }

  highlightTrackInPlaylist() {
    // handle the "active" classes
    if (document.querySelector('.tracklist li.active')) {
      document.querySelector('.tracklist li.active').classList.remove('active')
    }
    this.element.classList.add('active')
  }
	
  // calls in parallel with the frame updating
  selectTrack(e) {
		console.log('track selected')
		
		// we can't "promote" our frame loads to visits
		// via data-turbo-action="advance"
		// because we reset the player on turbo:load
		// this is just a hack to get history working 
		if (e.target.closest('a').href !== document.location.href) {
			const title = this.loadTrackTarget.textContent
			history.pushState(title, '', e.target.closest('a').href)
		}
    this.highlightTrackInPlaylist()
    this.showSmallCoverAndSidebarLinks()
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

  async setBigPlay(controller) {
	  console.log('big play set')
		this.bigPlay = controller
    this.bigPlayLoaded = true
    this.bigPlay.update(this.duration, this.currentTime, this.percentPlayed)
    this.bigPlay.setAnimationState(this.isPlaying)
  }

  disconnect() {
    super.disconnect()
  }
}
