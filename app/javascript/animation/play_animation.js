import { TweenLite, AttrPlugin, Linear, Elastic, Power1, Power2, Power3, Sine, CSSPlugin, TimelineMax } from 'gsap/all'
import MorphSVGPlugin from './MorphSVGPlugin'

const plugins = [CSSPlugin, AttrPlugin, MorphSVGPlugin, Linear, Elastic, Power1, Power2, Power3, Sine]

export default function PlayAnimation() {
  const mainSVG = document.getElementById('playAnimationSVG')
  const select = function (s) {
    return mainSVG.querySelector(s)
  }

  const selectAll = function (s) {
    return mainSVG.querySelectorAll(s)
  }

  let mainTl
  let dottyRotationTl
  let spinballTl

  let pauseGroup = select('.pauseGroup')
  let spinballGroup = select('.spinballGroup')

  let outline = select('.outline');
  let dotty = selectAll('.dotty');
  let icon = select('.icon');

  let outlinePath = 'M300,545C164.69,545,55,435.31,55,300S164.69,55,300,55,545,164.69,545,300,435.31,545,300,545Z';

  this.init = function () {
    pauseGroup = select('.pauseGroup');
    spinballGroup = select('.spinballGroup');

    outline = select('.outline');
    dotty = selectAll('.dotty');
    icon = select('.icon');

    outlinePath = 'M300,545C164.69,545,55,435.31,55,300S164.69,55,300,55,545,164.69,545,300,435.31,545,300,545Z';


    TweenLite.set(mainSVG, {
      visibility: 'visible'
    })

    TweenLite.set(dotty, {
      transformOrigin: '50% 50%',
      scale: 1.3,
    })

    TweenLite.set(spinballGroup, {
      transformOrigin: '50% 50%',
      scale: 0,
    })

    TweenLite.set(pauseGroup, {
      transformOrigin: '50% 50%',
      scaleY: 0,
    })

    spinballTl = new TimelineMax({}).timeScale(1);
    mainTl = new TimelineMax({ paused: true }).timeScale(2.2);

    dottyRotationTl = new TimelineMax({}).timeScale(1);
    dottyRotationTl.to(dotty, 4, {
      rotation: '-=360',
      repeat: -1,
      ease: Linear.easeNone,
    })

    mainTl.addLabel('setPlay')
      .addLabel('showLoading')
      .to(icon, 1, {
        morphSVG: { shape: outlinePath, shapeIndex: 'auto' },
        ease: Power1.easeInOut,
      })
      .to(dotty, 1, {
        scale: 1,
        ease: Power2.easeOut,
      }, '-=1')
      .to(outline, 0.5, {
        strokeWidth: 16,
        ease: Linear.easeNone,
      }, '-=0.5')
      .to(spinballGroup, 1, {
        scale: 1,
        ease: Power1.easeInOut,
      }, '-=1')
      .addPause()
      .addLabel('showPause')
      .to(spinballGroup, 1, {
        scale: 0,
        ease: Elastic.easeOut.config(0.3, 0.9),
      })
      .to(spinballGroup, 0.2, {
        // autoAlpha:0
      }, '-=1')
      .to(pauseGroup, 2, {
        scaleY: 0.7,
        ease: Elastic.easeOut.config(1, 0.5),
      }, '-=1')
      .to(dotty, 1, {
        scale: 1.3,
        ease: Elastic.easeOut.config(0.3, 0.9),
      }, '-=2')
      .addLabel('setPause')
    spinballTl.to(spinballGroup, 2, {
      rotation: '+=360',
      ease: Linear.easeNone,
      repeat: -1,
    })
  }

  this.setPlay = function () {
    mainTl.pause('setPlay')
  }

  this.showLoading = function () {
    mainTl.play('showloading')
  }

  this.showPause = function () {
    mainTl.play('showPause')
  }

  this.setPause = function () {
    mainTl.pause('setPause')
  }
}
