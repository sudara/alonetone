import PlaybackController from './playback_controller'
import LargePlayAnimation from '../animation/large_play_animation'
import Waveform from '../animation/waveform.coffee'

export default class extends PlaybackController {

  preInitialize() {
    this.animation = new LargePlayAnimation()
    this.animation.init()
    this.preload = true
  }

  postInitialize(){
    this.waveform = this.setupWaveform()
  }

  playCallback() {

  }

  whilePlayingCallback() {
    this.waveform.update()
  }

  setupWaveform() {
    const controller = this
    const data = this.data.get('waveform')
    return new Waveform({
      container: this.seekBarContainerTarget,
      height: 54,
      innerColor: function (percent, _) {
        if (percent < controller.sound.seek() / controller.sound.duration())
          return '#353535';
        else
          return '#c7c6c3';
      },
      data,
    })
  }
}