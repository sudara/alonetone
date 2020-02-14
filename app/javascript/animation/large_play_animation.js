import { gsap } from 'gsap'
import { MorphSVGPlugin } from './MorphSVGPlugin'

gsap.registerPlugin(MorphSVGPlugin)

export default function LargePlayAnimation() {

  var xmlns = "http://www.w3.org/2000/svg",
    xlinkns = "http://www.w3.org/1999/xlink",
    select = function(s) {
      return document.querySelector(s);
    },
    selectAll = function(s) {
      return document.querySelectorAll(s);
    },
    mainSVG = select('.largePlaySVG'),
    mainTl, dottyRotationTl,eyesTl,
    centerCircle = select('.centerCircle'),
    pauseContainer = select('.pauseContainer'),
    pauseLoopGroup = select('.pauseLoopGroup'),
    pauseGroup = select('.pauseGroup'),
    outline = select('.outline'),
    dotty = selectAll('.dotty'),
    icon = select('.icon'),
    allPauseLines = selectAll('.pauseGroup line')

  this.init = function() {

    this.reset()

    eyesTl = gsap.timeline({paused:true, repeat:-1}).timeScale(1.8);
    dottyRotationTl = gsap.timeline({}).timeScale(1.9);
    mainTl = gsap.timeline({paused:true}).timeScale(2.6);

    dottyRotationTl.to(dotty, 4, {
      rotation:360,
      repeat:-1,
      ease:'none',
    })

    // eyes timeline

    eyesTl.to(pauseLoopGroup, 0.4, {
      scaleY:0.12,
      ease: 'sine.inOut',
    })
    .to(pauseLoopGroup, 0.4, {
      scaleY:0,
      repeat:1,
      yoyo:true,
      repeatDelay:0.41,
      ease: 'sine.in',
      delay:1,
    })
   .to(pauseLoopGroup, 0.65, {
      scaleY:0.25,
      repeat:1,
      yoyo:true,
      repeatDelay:0,
      delay:1.5,
      ease: 'power1.inOut',
    })
    .to(pauseLoopGroup, 0.2, {
      scaleY:0.12,
      ease: 'sine.out',
    })
    .to(pauseLoopGroup, 0.16, {
      scaleY:0.01,
      repeat:1,
      yoyo:true,
      ease: 'sine.in',
      delay:2,
    })
    .to(pauseLoopGroup, 0.16, {
      scaleY:0.01,
      repeat:3,
      yoyo:true,
      ease: 'sine.in',
      delay:4,
    })
    .to(pauseLoopGroup, 0.16, {
      scaleY:0,
      ease: 'sine.in',
      delay:1,
    })

    // main timeline

    mainTl
      .addLabel('setPlay')
      .addLabel('showLoading')
      .to(dotty, 1, {
        strokeWidth:128,
        scale:1,
        ease: 'power1.inOut',
      })
      .to(icon, 1, {
        scale:0.4,
        ease: 'power1.inOut',
      },'-=1')
      .from(centerCircle, 1, {
        scale:0.01,
        ease: 'power1.inOut',
      },'-=1')
      .to(outline, 1, {
        strokeWidth:30,
        scale:0.97,
        stroke: '#000',
        ease: 'power1.inOut',
      },'-=1')
      .to(pauseContainer, 1, {
        scaleY:1,
        ease: 'power1.inOut',
      })
      .addPause()
      .addLabel('showPause')
      .to(pauseContainer, 0.5, {
        scaleY:0,
      })
      .to(centerCircle, 1, {
        attr:{
          r:245,
        },
      ease: 'power1.inOut',
      },'-=0.5')
      .to(dotty, 1.2, {
        strokeWidth:0,
        scale:1,
        ease: 'power1.inOut',
      },'-=1')
      .to(pauseGroup, 1, {
        scaleY:1,
        ease: 'power1.inOut',
      },'-=1.2')
      .to(allPauseLines, { duration: 1, attr: gsap.utils.wrap([{ x1: 235, x2: 235 }, { x1: 365, x2: 365 }]) }, '-=1')
      .addLabel('setPause')
  }

  this.play = function(pos) {
    if(pos){mainTl.play(pos);} return;
    mainTl.play();
  }

  this.pause = function(pos) {
    if(pos){mainTl.pause(pos);} return;
    mainTl.pause();
  }

  this.timeline = function() {
    return mainTl;
  }

  this.setPlay = function(){
    mainTl.pause('setPlay')
  }

  this.showLoading = function(){
    gsap.set(".dotty", { visibility: "visible" });
    gsap.set(".pauseContainer", { visibility: "visible" });
    gsap.set(".centerCircle", { visibility: "visible" });
    mainTl.play('showloading')
    eyesTl.play();
  }

  this.reset = function() {
    gsap.set([dotty, centerCircle], {
      transformOrigin: '50% 50%',
      strokeWidth: 0,
    })

    gsap.set(icon, {
      transformOrigin: '35% 50%',
    })

    gsap.set(outline, {
      transformOrigin: '50% 50%',
    })

    gsap.set([pauseContainer, pauseGroup, pauseLoopGroup], {
      transformOrigin: '50% 50%',
      scaleY: 0,
      visibility: 'visible',
    })
    gsap.set(mainSVG, {
      visibility: 'visible',
    })
  }

  this.showPause = function(){
    mainTl.play('showPause')
  }

  this.setPause = function(){
    mainTl.pause('setPause')
  }

}
