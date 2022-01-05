import { Controller } from "@hotwired/stimulus"
import { gsap } from 'gsap'
import LargePlayAnimation from '../animation/large_play_animation'

export default class extends Controller {
  static targets = ['play', 'playButton', 'time', 'progressContainerInner', 'waveform', 'seekBar']

  initialize() {
		console.log('initted...')
    this.animation = new LargePlayAnimation()
    this.duration = 0.0
    this.percentPlayed = 0.0
    this.setupPlayhead()
  }

	// reach out to the playlist and connect to the active playing track
	// called every time the controller's element is added to the dom
 	connect() {
		console.log('connecting...')
    this.setDelegate()
	}
	
  // called from whileLoading()
  load(duration) {
    this.duration = duration
  }

  // this is listened for by single-playback
  // but also called from playlist-playback
  seeked() {
    this.timeline.play()
  }

  // called from the player on playing() & whilePlaying()
  update(duration, currentTime, percentPlayed) {
    this.duration = duration
    this.timeTarget.innerHTML = currentTime
    this.percentPlayed = percentPlayed
    //console.log(`playhead: ${this.timeline.progress()} percentPlayed: ${this.percentPlayed}`)

    // This check performs 2 functions
    // 1. It's repsonsible for catching the playhead on seek
    // 2. It prevents the gsap-powered playhead from drifting
    if ((Math.abs(percentPlayed - this.timeline.progress()) > 0.02)) {
      //console.log(`playhead jogged from ${this.timeline.progress()} to ${this.percentPlayed}`)
      this.timeline.progress(percentPlayed)
    }
  }

  // update should be called before this
  setAnimationState(isPlaying) {
    if (isPlaying && (this.percentPlayed === 0.0)) {
      // play was clicked, mp3 is still loading
      this.animation.loadingAnimation()
    } else if (isPlaying) {
      // in the middle of playing
      this.startPlayhead()
    } else if (this.percentPlayed > 0.0) {
      // was playing once but now paused
      this.animation.showPlayButton()
      this.showPlayhead()
    } else {
      // ....loaded but not playing
      this.animation.showPlayButton()
    }
  }

  // the single/playlist controller that we are linked to
  setDelegate() {
		
		// how do we know which track we are delegating to?
		// the source of authority has to be the active track in the sidebar
    const itemInPlaylist = document.querySelector('.tracklist li.active')
    if (itemInPlaylist) this.delegate = this.application.getControllerForElementAndIdentifier(itemInPlaylist, 'playlist-playback')
    else {
      this.delegate = this.application.getControllerForElementAndIdentifier(this.element, 'single-playback')
    }
		this.delegate.setBigPlay(this)
  }

  // called from the delegate's playing()
  play() {
    this.animation.pausingAnimation()
    this.startPlayhead()
  }

  pause() {
    this.timeline.pause()
    this.animation.showPlayButton()
  }

  togglePlay(e) {
    this.delegate.fireClick()
    e.preventDefault()
  }

  skim(e) {
    const offx = e.clientX - this.waveformTarget.getBoundingClientRect().left
    this.seekBarTarget.style.left = `${offx}px`
  }

  seek(e) {
    const offset = e.clientX - this.waveformTarget.getBoundingClientRect().left
    const newPosition = offset / this.waveformTarget.offsetWidth
    this.delegate.seek(newPosition)
    this.timeline.pause()
    this.timeline.seek(newPosition)
  }

  stop() {
    this.animation.showPlayButton()
    this.timeline.pause()
  }

  setupPlayhead() {
    this.timeline = gsap.timeline({ paused: true, duration: 1 })
    this.playheadAnimation = this.timeline.to(this.progressContainerInnerTarget, {
      duration: 1,
      left: '100%',
      ease: 'none',
    }, 0)
    this.waveformAnimation = this.timeline.to('#waveform_reveal', {
      duration: 1,
      attr: { x: '0' },
      ease: 'none',
    }, 0)
  }

  startPlayhead() {
    this.showPlayhead()
    this.timeline.play()
  }

  showPlayhead() {
    this.progressContainerInnerTarget.classList.add('visible')
    if (this.timeline.duration() === 1) {
      this.timeline.duration(this.duration) // gsap 3.2.4 broke duration getter, working again
    }
  }

  disconnect() {
    this.animation.reset()
  }
}
