import { gsap } from 'gsap'
import { MorphSVGPlugin } from './MorphSVGPlugin'

gsap.registerPlugin(MorphSVGPlugin)

export default class PlayAnimation {
  constructor(mainSVG) {
    this.mainSVG = mainSVG

    this.pauseGroup = this.select('.pauseGroup')
    this.spinballGroup = this.select('.spinballGroup')
    this.outline = this.select('.outline')
    this.dotty = this.selectAll('.dotty')
    this.icon = this.select('.icon')
    this.outlinePath = 'M300,545C164.69,545,55,435.31,55,300S164.69,55,300,55,545,164.69,545,300,435.31,545,300,545Z';

    this.tl = gsap.timeline({ paused: true }).timeScale(2.2);
    this.spinballTl = gsap.timeline().timeScale(1);
    this.dottyRotationTl = gsap.timeline().timeScale(1);
  }

  init() {
    gsap.set(this.mainSVG, {
      visibility: 'visible',
    })

    gsap.set(this.dotty, {
      transformOrigin: '50% 50%',
      scale: 1.3,
    })

    gsap.set(this.spinballGroup, {
      transformOrigin: '50% 50%',
      scale: 0,
    })

    gsap.set(this.pauseGroup, {
      transformOrigin: '50% 50%',
      scaleY: 0,
    })

    this.spinballTl.to(this.spinballGroup, 2, {
      rotation: '+=360',
      ease: 'none',
      repeat: -1,
    })

    this.dottyRotationTl.to(this.dotty, 4, {
      rotation: '-=360',
      repeat: -1,
      ease: 'none',
    })

    this.tl.addLabel('playButton')
      .addLabel('loadingAnimation')
      .to(this.icon, 1, {
        morphSVG: { shape: this.outlinePath, shapeIndex: 'auto' },
        ease: 'power1.inOut',
      })
      .to(this.dotty, 1, {
        scale: 1,
        ease: 'power2.out',
      }, '-=1')
      .to(this.outline, 0.5, {
        strokeWidth: 16,
        ease: 'none',
      }, '-=0.5')
      .to(this.spinballGroup, 1, {
        scale: 1,
        ease: 'power1.inOut',
      }, '-=1')
      .addPause()
      .addLabel('pauseAnimation')
      .to(this.spinballGroup, 1, {
        scale: 0,
        ease: 'elastic(0.3, 0.9)',
      })
      .to(this.spinballGroup, 0.2, {
        autoAlpha: 0
      }, '-=1')
      .to(this.pauseGroup, 2, {
        scaleY: 0.7,
        ease: 'elastic(1, 0.5)',
      }, '-=1')
      .to(this.dotty, 1, {
        scale: 1.3,
        ease: 'elastic(0.3, 0.9)',
      }, '-=2')
      .addLabel('pauseButton')
  }

  select(s) {
    return this.mainSVG.querySelector(s)
  }

  selectAll(s) {
    return this.mainSVG.querySelectorAll(s)
  }

  loadingAnimation() {
    this.tl.play('loadingAnimation')
    this.dottyRotationTl.play()
  }

  pauseAnimation() {
    this.tl.play('pauseAnimation')
    this.dottyRotationTl.pause()
  }

  showPlayButton() {
    this.tl.pause('playButton')
  }

  showPauseButton() {
    this.tl.pause('pauseButton')
  }
}
