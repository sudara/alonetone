import { gsap } from 'gsap'
import { MorphSVGPlugin } from './MorphSVGPlugin'

if (MorphSVGPlugin) gsap.registerPlugin(MorphSVGPlugin)

export default class LargePlayAnimation {
  constructor(elementToReplace) {
    this.mainSVG = document.querySelector('.largePlaySVG')
    this.setupTimelines()
  }

  setupTimelines() {
    this.eyesTl = gsap.timeline({ repeat: -1 }).timeScale(1.8);
    this.dottyRotationTl = gsap.timeline({}).timeScale(1.9);
    this.tl = gsap.timeline({ paused: true }).timeScale(2.6);

    this.centerCircle = this.select('.centerCircle')
    this.pauseContainer = this.select('.pauseContainer')
    this.pauseLoopGroup = this.select('.pauseLoopGroup')
    this.pauseGroup = this.select('.pauseGroup')
    this.outline = this.select('.outline')
    this.dotty = this.selectAll('.dotty')
    this.icon = this.select('.icon')
    this.allPauseLines = this.selectAll('.pauseGroup line')

    gsap.set([this.dotty, this.centerCircle], {
      transformOrigin: '50% 50%',
      strokeWidth: 0,
      visibility: 'visible',
    })

    gsap.set(this.icon, {
      transformOrigin: '35% 50%',
      visibility: 'visible',
    })

    gsap.set(this.outline, {
      transformOrigin: '50% 50%',
      visibility: 'visible',
    })

    gsap.set([this.pauseContainer, this.pauseGroup, this.pauseLoopGroup], {
      transformOrigin: '50% 50%',
      scaleY: 0,
      visibility: 'visible',
    })

    this.dottyRotationTl.to(this.dotty, 4, {
      rotation: 360,
      repeat: -1,
      ease: 'none',
    })

    // eyes timeline
    this.eyesTl.to(this.pauseLoopGroup, 0.4, {
      scaleY: 0.12,
      ease: 'sine.inOut',
    })
    .to(this.pauseLoopGroup, 0.4, {
      scaleY: 0,
      repeat: 1,
      yoyo: true,
      repeatDelay: 0.41,
      ease: 'sine.in',
      delay: 1,
    })
   .to(this.pauseLoopGroup, 0.65, {
      scaleY: 0.25,
      repeat: 1,
      yoyo: true,
      repeatDelay: 0,
      delay: 1.5,
      ease: 'power1.inOut',
    })
    .to(this.pauseLoopGroup, 0.2, {
      scaleY: 0.12,
      ease: 'sine.out',
    })
    .to(this.pauseLoopGroup, 0.16, {
      scaleY: 0.01,
      repeat: 1,
      yoyo: true,
      ease: 'sine.in',
      delay: 2,
    })
    .to(this.pauseLoopGroup, 0.16, {
      scaleY: 0.01,
      repeat: 3,
      yoyo: true,
      ease: 'sine.in',
      delay: 4,
    })
    .to(this.pauseLoopGroup, 0.16, {
      scaleY: 0,
      ease: 'sine.in',
      delay: 1,
    })

    // main timeline
    this.tl
      .addLabel('playButton')
      .addLabel('loadingAnimation')
      .to(this.dotty, 1, {
        strokeWidth: 128,
        scale: 1,
        ease: 'power1.inOut',
      })
      .to(this.icon, 1, {
        scale: 0.4,
        ease: 'power1.inOut',
      }, '-=1')
      .from(this.centerCircle, 1, {
        scale: 0.01,
        ease: 'power1.inOut',
      }, '-=1')
      .to(this.outline, 1, {
        strokeWidth: 30,
        scale: 0.97,
        stroke: '#000',
        ease: 'power1.inOut',
      }, '-=1')
      .to(this.pauseContainer, 1, {
        scaleY: 1,
        ease: 'power1.inOut',
      })
      .addPause()
      .addLabel('pausingAnimation')
      .to(this.pauseContainer, 0.5, {
        scaleY: 0,
      })
      .to(this.centerCircle, 1, {
        attr: {
          r: 245,
        },
        ease: 'power1.inOut',
      }, '-=0.5')
      .to(this.dotty, 1.2, {
        strokeWidth: 0,
        scale: 1,
        ease: 'power1.inOut',
      }, '-=1')
      .to(this.pauseGroup, 1, {
        scaleY: 1,
        ease: 'power1.inOut',
      }, '-=1.2')
      .to(this.allPauseLines, { duration: 1, attr: gsap.utils.wrap([{ x1: 235, x2: 235 }, { x1: 365, x2: 365 }]) }, '-=1')
      .addLabel('pauseButton')
  }


  loadingAnimation() {
    this.tl.play('loadingAnimation')
  }

  pausingAnimation() {
    this.tl.play('pausingAnimation')
  }

  showPlayButton() {
    this.tl.pause('playButton')
  }

  showPauseButton() {
    this.tl.pause('pauseButton')
  }

  reset() {
    gsap.set([this.dotty, this.centerCircle, this.icon, this.outline,
      this.pauseContainer, this.pauseGroup, this.pauseLoopGroup], {
      clearProps: 'all',
    })
  }

  select(s) {
    return this.mainSVG.querySelector(s)
  }

  selectAll(s) {
    return this.mainSVG.querySelectorAll(s)
  }
}
