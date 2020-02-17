/*

There are 3 things that make this svg/animation tricky to implement.

1. We want the resting state of the svg to be a play button, but certain elements have to be hidden for it not to be a cluttered ball of junk. On this small play button, we actually only swap in the animation svg once play is pressed. On the large play button we hide the problematic svg elements until the animation is initialized in js.

2. Attaching these animations to an svg element is not idempotent, as everything is scaled as it is first attached. This becomes problematic because if we navigate away from a page and then come back via turbolinks, the svg has been modified in the DOM, but the animation then modifies and scales it up again.

3. More than one copy of the svg cannot occur on the page at one time without changing the mask ids. This seems to be a general limitation of masking with svg.

*/

import { gsap } from 'gsap'
import { MorphSVGPlugin } from './MorphSVGPlugin'

gsap.registerPlugin(MorphSVGPlugin)

export default class PlayAnimation {
  constructor(elementToReplace) {
    this.cloneSVGFrom(document.querySelector('#playAnimationSVG'))
    this.replaceElementWithClonedSVG(elementToReplace)

    this.pauseGroup = this.select('.pauseGroup')
    this.spinballGroup = this.select('.spinballGroup')
    this.outline = this.select('.outline')
    this.dotty = this.selectAll('.dotty')
    this.icon = this.select('.icon')
    this.outlinePath = 'M300,545C164.69,545,55,435.31,55,300S164.69,55,300,55,545,164.69,545,300,435.31,545,300,545Z';


    this.setupTimelines()
  }

  // The svg used in this animation contains a mask.
  // Masks have to be referenced by id.
  // This makes it impossible to have multiple of these svgs
  // on one page without explicitly changing the id.
  // This forces us to "just in time" clone the svg before animating it
  cloneSVGFrom(mainSVG) {
    this.svg = mainSVG.cloneNode(true)
    this.svg.id = ''
    const mask = this.svg.querySelector('mask')
    mask.id = Math.random().toString(36).substr(2, 9)
    const iconGroup = this.svg.querySelector('.iconGroup')
    iconGroup.setAttribute('mask', `url(#${mask.id})`)
  }

  replaceElementWithClonedSVG(elementToReplace) {
    this.oldElement = elementToReplace.cloneNode(true)
    elementToReplace.parentNode.replaceChild(this.svg, elementToReplace)
  }

  replaceClonedSVGWithOldElement() {
    this.svg.parentNode.replaceChild(this.oldElement, this.svg)
  }

  setupTimelines() {
    this.tl = gsap.timeline({ paused: true }).timeScale(2.2);
    this.spinballTl = gsap.timeline().timeScale(1);
    this.dottyRotationTl = gsap.timeline().timeScale(1);
    this.tl
      .set(this.dotty, {
        transformOrigin: 'center center',
        scale: 1.3,
      })
      .set(this.spinballGroup, {
        transformOrigin: 'center center',
        scale: 0,
      })
      .set(this.pauseGroup, {
        transformOrigin: 'center center',
        scaleY: 0,
      })
      .addLabel('playButton') // starting state
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
      .addLabel('pausingAnimation')
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
    return this.svg.querySelector(s)
  }

  selectAll(s) {
    return this.svg.querySelectorAll(s)
  }

  loadingAnimation() {
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
    this.tl.play('loadingAnimation')
  }

  pausingAnimation() {
    this.tl.play('pausingAnimation')
    this.dottyRotationTl.pause()
    this.spinballTl.pause()
  }

  showPlayButton() {
    this.tl.pause('playButton')
  }

  showPauseButton() {
    this.tl.pause('pauseButton')
  }

  // Because we navigate back and forth via turbolinks
  // We might connect with an svg that was already partially animated
  // This is called on stimulus disconnect to reset the animation's state
  reset() {
    this.replaceClonedSVGWithOldElement()
  }
}
