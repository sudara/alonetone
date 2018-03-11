import { Controller } from 'stimulus'
import { playAnimation } from '../animation/play_animation'

let player
let currentlyOpen
const animation = new PlayAnimation();

function soundID(url) {
  let user, 
permalink;
  url = url.replace(/^\/+/, '').replace(/\/+$/, '')
  user = url.split('/').shift()
  permalink = url.split('/').pop().split('.')[0]
  return `${user}/${permalink}`
}

export default class extends Controller {
  // data-asset-playing="0" data-asset-opened="0">
  static targets = ['play', 'playButton', 'title', 'seekbar', 'details']

  initialize() {
    const controller = this
    this.isPlaying = false
    this.url = this.playTarget.firstElementChild.getAttribute('href')
    this.soundID = soundID(this.url)
    console.log(this.url)
    this.sound = new Howl({
      src: Array(this.url),
      html5: true,
      preload: false,
      // onend: this.playNextTrack.bind(this),
      onplay() {
        animation.showPause()
        requestAnimationFrame(controller.whilePlaying.bind(controller))
      },
      onload() {
        console.log(this.seek())
      },
    })
  }

  disconnect() {
    this.pause()
  }

  whilePlaying() {
    console.log(`${this.sound.seek()}`)
    if (this.sound.playing()) {
      setTimeout(requestAnimationFrame(this.whilePlaying.bind(this)), 100);
    }
  }

  play() {
    if (player) {
      player.pause()
    }
    player = this
    this.isPlaying = true
    this.animateLoading()
    this.seekbarTarget.style.display = 'block'
    this.element.classList.add('playing')
    this.sound.load()
    this.sound.play()
    console.log(this.sound)
  }

  pause() {
    this.sound.pause()
    player = null
    this.isPlaying = false
    animation.setPlay()
  }

  togglePlay(e) {
    e.preventDefault()
    if (this.isPlaying) {
      this.pause()
    } else {
      this.play()
    }
  }

  animateLoading() {
    this.playButtonTarget.style.display = 'none'
    this.playTarget.firstElementChild.append(document.getElementById('playAnimationSVG'))
    animation.init()
    animation.setPlay()
    animation.showLoading()
  }

  toggleDetails(e) {
    e.preventDefault()
    const wasOpen = this.element.classList.contains('open')
    // if another track details is open, close it
    if (currentlyOpen) {
      currentlyOpen.element.classList.remove('open')
    }
    if (!wasOpen) {
      currentlyOpen = this
      this.element.classList.add('open')
    }
  }

  createSound() {

  }

  playNextTrack() {
    const next = this.element.nextSibling
    this.getControllerForElementAndIdentifier(next, 'asset').play()
  }
}
