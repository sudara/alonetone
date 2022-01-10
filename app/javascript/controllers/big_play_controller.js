import { Controller } from "@hotwired/stimulus"
import { gsap } from 'gsap'
import LargePlayAnimation from '../animation/large_play_animation'

/*

Mental model for playlist-track-playback and big-play can be confusing.

> big player

> track one
> track two

When a playlist-track's play button is pressed, it's first handled by stitches.

The playlist-track listens to the stitches event
    track:play->playlist-track-playback#play


Animations:
    this.animation.loadingAnimation()
    this.animation.pausingAnimation()
    this.animation.showPlayButton()



*/

export default class extends Controller {
  static targets = ['play', 'playButton', 'time', 'progressContainerInner', 'waveform', 'seekBar']

  static values = {
     trackId: Number,
   }

  initialize() {
		// we don't have access to the playlist's true state
    this.animation = new LargePlayAnimation()
    this.duration = 0.0
    this.percentPlayed = 0.0
    this.setupPlayhead()
  }

	// reach out to the playlist and connect to the active playing track
	// called every time the controller's element is added to the dom
 	connect() {
    this.setupPlayhead()
		this.dispatch("connected", { detail: { trackId: this.trackIdValue } })
	}

  // this is listened for by single-playback
  // but also called from playlist-track-playback
  seeked() {
    this.timeline.play()
  }

  // responding to the stitches track:play event
  play(event) {
		this.animation.loadingAnimation()
  }

  // this is the first "whilePlaying" call
  playing(event) {
		if(event.detail.trackId != this.trackIdValue) return;
    this.whilePlaying(event)
    this.animation.pausingAnimation()
    this.startPlayhead()
  	this.isPlaying = true
  }

  whileLoading(event) {
		if(event.detail.trackId != this.trackIdValue) return;
		console.log('whilest load', event.detail)
    this.duration = event.detail.duration
  }

  whilePlaying(event) {
		if(event.detail.trackId != this.trackIdValue) return;
    this.duration = event.detail.duration
    this.timeTarget.innerHTML = event.detail.currentTime
    this.percentPlayed = event.detail.percentPlayed
    //console.log(`playhead: ${this.timeline.progress()} percentPlayed: ${this.percentPlayed}`)

    // This check performs 2 functions
    // 1. It's repsonsible for catching the playhead on seek
    // 2. It prevents the gsap-powered playhead from drifting
    if ((Math.abs(this.percentPlayed - this.timeline.progress()) > 0.02)) {
      //console.log(`playhead jogged from ${this.timeline.progress()} to ${this.percentPlayed}`)
      this.timeline.progress(this.percentPlayed)
    }
  }

	// dispatched event from playlist_track_playback
  updateState(event) {
		// we only care about the state from the right trackId
		if (event.detail.trackId != this.trackIdValue) return;

    // set current time / duration / percent played
		this.whilePlaying(event)

    if (event.detail.isPlaying && (event.detail.percentPlayed === 0.0)) {
      // play was clicked, mp3 is still loading
      this.animation.loadingAnimation()
    } else if (event.detail.isPlaying) {
      // in the middle of playing
			this.animation.pausingAnimation()
    	this.timeline.progress(event.detail.percentPlayed)
      this.startPlayhead()
    } else if (event.detail.percentPlayed > 0.0) {
      // was playing once but now paused
    	this.timeline.progress(event.detail.percentPlayed)
      this.animation.showPlayButton()
      this.showPlayhead()
    } else {
      // ....loaded but not playing
      this.animation.showPlayButton()
    }
  }

  pause() {
    this.timeline.pause()
    this.animation.showPlayButton()
		this.isPlaying = false
  }

	stop() {
		this.isPlaying = false
	}

  togglePlay(e) {
    console.log('toggle play called')
		if (this.percentPlayed == 0)
			this.animation.loadingAnimation()
		this.dispatch("togglePlay", { detail: { trackId: this.trackIdValue } })
    e.preventDefault()
  }

  skim(e) {
    const offx = e.clientX - this.waveformTarget.getBoundingClientRect().left
    this.seekBarTarget.style.left = `${offx}px`
  }

  seek(e) {
    const offset = e.clientX - this.waveformTarget.getBoundingClientRect().left
    const newPosition = offset / this.waveformTarget.offsetWidth
		this.dispatch("seek", { detail: { trackId: this.trackIdValue, position: newPosition } })
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
