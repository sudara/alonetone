import { Controller } from 'stimulus'
import { Howl } from 'howler'
import PlayAnimation from '../animation/play_animation'
import LargePlayAnimation from '../animation/large_play_animation'
import Waveform from '../animation/waveform.coffee'

let player
let currentlyOpen
let animation
const playAnimation = new PlayAnimation()
const largePlayAnimation = new LargePlayAnimation()

function soundID(url) {
  url = url.replace(/^\/+/, '').replace(/\/+$/, '')
  const user = url.split('/').shift()
  const permalink = url.split('/').pop().split('.')[0]
  return `${user}/${permalink}`
}

export default class extends Controller {
  // data-asset-playing="0" data-asset-opened="0">
  static targets = ['play', 'playButton', 'title', 'details',
    'seekBarContainer', 'seekBarLoaded', 'seekBarPlayed']

  initialize() {
    this.isPlaying = false
    this.url = this.playTarget.querySelector('a').getAttribute('href')
    this.setupHowl()
    if (this.inPlaylist()) {
      animation = new LargePlayAnimation()
      animation.init()
      this.waveform = this.setupWaveform()
    } else {
      animation = playAnimation
    }
  }

  inPlaylist() {
    return this.data.has('inPlaylist') === true
  }

  disconnect() {
    if (this.sound.playing()) {
      this.sound.pause()
    }
  }

  setupHowl() {
    const controller = this
    this.sound = new Howl({
      src: Array(this.url),
      html5: true,
      preload: this.inPlaylist(),
      onend: controller.playNextTrack.bind(controller),
      onplay() {
        requestAnimationFrame(controller.whilePlaying.bind(controller))
      },
      onload() {

      },
    })
  }

  whilePlaying() {
    // console.log(`${this.sound.seek()}`)
    if (this.inPlaylist()) {
      this.waveform.update()
    } else {
      this.updateSeekBarPlayed()
    }
    if (this.sound.playing()) {
      animation.setPause()
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
    if (this.inPlaylist()){

    } else {
      this.openDetails()
      this.updateSeekBarLoaded()
    }
    this.element.classList.add('playing')
    this.sound.play()
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

  seek(e) {
    e.preventDefault()
    const newPosition = e.offsetX / this.seekBarContainerTarget.offsetWidth
    this.sound.seek(this.sound.duration() * newPosition)
  }

  // With SoundManager we used to animate this width to display
  // how much of the track is downloaded
  // but it's no longer possible with Howl
  updateSeekBarLoaded() {
    this.seekBarContainerTarget.style.display = 'block'
    this.seekBarLoadedTarget.style.width = '100%'
  }
  updateSeekBarPlayed() {
    const position = this.sound.seek() / this.sound.duration()
    const maxwidth = this.seekBarLoadedTarget.offsetWidth
    this.seekBarPlayedTarget.style.width = `${position * maxwidth}px`
  }

  animateLoading() {
    if (!this.inPlaylist()) {
      this.playButtonTarget.style.display = 'none'
      this.playTarget.firstElementChild.append(document.getElementById('playAnimationSVG'))
      animation.init()
      animation.setPlay()
    }
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
      this.openDetails()
    }
  }

  openDetails() {
    if (currentlyOpen) {
      currentlyOpen.element.classList.remove('open')
    }
    currentlyOpen = this
    this.element.classList.add('open')
  }

  playNextTrack() {
    const next = this.element.nextSibling
    this.getControllerForElementAndIdentifier(next, 'asset').play()
  }

  skim(e) {
    const offx = e.clientX - this.seekBarContainerTarget.getBoundingClientRect().left
    this.seekBarLoadedTarget.style.left = `${offx}px`
  }

  setupWaveform() {
    const soundPosition = 0
    const data = this.data.get('waveform')
    return new Waveform({
      container: this.seekBarContainerTarget,
      height: 54,
      innerColor: function (percent, _) {
        if (percent < soundPosition)
          return '#302fg2f';
        else
          return '#c7c6c3';
      },
      data,
    })
  }
}
