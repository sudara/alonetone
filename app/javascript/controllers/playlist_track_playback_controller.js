import PlaybackController from './playback_controller'

const smallCover = document.querySelector('a.small_cover')
const sidebarLinks = document.querySelector('.sidebar_downloads')

// This is a controller for ONE mp3, one <li>
export default class extends PlaybackController {
  static targets = ['play', 'loadTrack']

  static values = {
     trackId: Number,
   }

  initialize() {
		this.percentPlayed = 0
		this.duration = 0
    this.currentTime = ""
    this.permalink = this.playTarget.getAttribute('href').split('/').pop()
  }

  // bigPlay issues this event when its play button is clicked
  togglePlay(event) {
		if (event.detail.trackId == this.trackIdValue)
    {
			this.playTarget.click()
    }
  }

  // After PlaybackController#play is called, this stuff fires
  playCallback(e) {
    if (!this.isCurrentTrack()) {
			 // Load in the track and call selectTrack
       this.loadTrackTarget.click()
     }
    this.registeredListen = false
    this.playTarget.classList.replace('play_button', 'pause_button')
    this.playTarget.firstElementChild.setAttribute('data-icon', 'pause')
  }

	// we only need this to track state for when big play dissapears
  whilePlaying(event) {
		this.duration = event.detail.duration
    this.percentPlayed = event.detail.percentPlayed
    this.currentTime = event.detail.currentTime
	}

  pauseCallback() {
    this.playTarget.classList.replace('pause_button', 'play_button')
    this.playTarget.firstElementChild.setAttribute('data-icon', 'play')
  }

  stopCallback() {
    this.playTarget.classList.replace('pause_button', 'play_button')
    this.playTarget.firstElementChild.setAttribute('data-icon', 'play')
  }

	// dispatched from big_play#connect
	// lets us know which track was just loaded
	// and we send back the play state
	connectBigPlay(event) {
		if (event.detail.trackId == this.trackIdValue)
		{
			this.dispatch("updateState", { detail: { trackId: this.trackIdValue, isPlaying: this.isPlaying, duration: this.duration, currentTime: this.currentTime, percentPlayed: this.percentPlayed } })
		}
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

  // called before the ajax load into the frame
  selectTrack(e) {
		console.log('track selected')
		// we can't "promote" our frame loads to visits
		// via data-turbo-action="advance"
		// because we reset the player on turbo:load
		// this is just a hack to get history working
		// we gsub the mp3 out in case it's a play link
		const href = e.target.closest('a').href.replace('.mp3','')
		if (href !== document.location.href) {
			const title = this.loadTrackTarget.textContent
			history.pushState(title, '', href)
      this.highlightTrackInPlaylist()
      this.showSmallCoverAndSidebarLinks()
		}
    else {
      e.preventDefault() // don't fire the ajax call if same page
    }
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

  isCurrentTrack() {
     return this.playTarget.getAttribute('href').replace('.mp3', '') === document.location.pathname
   }

  seek(event) {
		if (event.detail.trackId != this.trackIdValue) return

    const stitchesEvent = new CustomEvent('track:seek', { 'detail': { 'position': event.detail.position }, 'bubbles': true })
    this.element.dispatchEvent(stitchesEvent)
  }

  disconnect() {
    super.disconnect()
  }
}
