import { TweenLite, AttrPlugin, Linear, Elastic, Power1, Power2, Power3, Sine, CSSPlugin, TimelineMax } from 'gsap/all'
import MorphSVGPlugin from './MorphSVGPlugin'

const plugins = [CSSPlugin, AttrPlugin, MorphSVGPlugin, Linear, Elastic, Power1, Power2, Power3, Sine]

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

    eyesTl = new TimelineMax({paused:true, repeat:-1}).timeScale(1.8);
    dottyRotationTl = new TimelineMax({}).timeScale(1.9);
    mainTl = new TimelineMax({paused:true}).timeScale(2.6);

    dottyRotationTl.to(dotty, 4, {
      rotation:360,
      repeat:-1,
      ease:Linear.easeNone
    })

    // eyes timline

    eyesTl.to(pauseLoopGroup, 0.4, {
      scaleY:0.12,
      ease:Sine.easeInOut
    })
    .to(pauseLoopGroup, 0.4, {
      scaleY:0,
      repeat:1,
      yoyo:true,
      repeatDelay:0.41,
      ease:Sine.easeIn,
      delay:1
    })
   .to(pauseLoopGroup, 0.65, {
      scaleY:0.25,
      repeat:1,
      yoyo:true,
      repeatDelay:0,
      delay:1.5,
      ease:Power1.easeInOut
    })
    .to(pauseLoopGroup, 0.2, {
      scaleY:0.12,
      ease:Sine.easeOut
    })
    .to(pauseLoopGroup, 0.16, {
      scaleY:0.01,
      repeat:1,
      yoyo:true,
      //repeatDelay:0.41,
      ease:Sine.easeIn,
      delay:2
    })
    .to(pauseLoopGroup, 0.16, {
      scaleY:0.01,
      repeat:3,
      yoyo:true,
      //repeatDelay:0.41,
      ease:Sine.easeIn,
      delay:4
    })
    .to(pauseLoopGroup, 0.16, {
      scaleY:0,
      //repeatDelay:0.41,
      ease:Sine.easeIn,
      delay:1
    })

   // main timeline

    mainTl.addLabel('setPlay')
      .addLabel('showLoading')
      .to(dotty, 1, {
      strokeWidth:128,
      scale:1,
      ease:Power1.easeInOut
    })
    .to(icon, 1, {
      scale:0.4,
      ease:Power1.easeInOut
    },'-=1')
    .from(centerCircle, 1, {
      scale:0.01,
      ease:Power1.easeInOut
    },'-=1')
    .to(outline, 1, {
      strokeWidth:30,
      scale:0.97,
      stroke: '#000',
      ease:Power1.easeInOut
    },'-=1')
    .to(pauseContainer, 1, {
      scaleY:1,
      ease:Power1.easeInOut
    })
    .addPause()
    .addLabel('showPause')
    .to(pauseContainer, 0.5, {
      scaleY:0
    })
    .to(centerCircle, 1, {
      attr:{
        r:245
      },
    ease:Power1.easeInOut
    },'-=0.5')
    .to(dotty, 1.2, {
      strokeWidth:0,
      scale:1,
      ease:Power1.easeInOut
    },'-=1')
    .to(pauseGroup, 1, {
      scaleY:1,
      ease:Power1.easeInOut
      //ease:Elastic.easeOut.config(0.95,0.3)
    },'-=1.2')
    .staggerTo(allPauseLines, 1, {
      cycle:{
        attr:[{x1:235, x2:235}, {x1:365, x2:365}]
      }
    },0, '-=1')
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
    TweenLite.set(".dotty", { visibility: "visible" });
    TweenLite.set(".pauseContainer", { visibility: "visible" });
    TweenLite.set(".centerCircle", { visibility: "visible" });
    mainTl.play('showloading')
    eyesTl.play();
  }

  this.reset = function() {
    TweenLite.set([dotty, centerCircle], {
      transformOrigin: '50% 50%',
      strokeWidth: 0
    })

    TweenLite.set(icon, {
      transformOrigin: '35% 50%',
      scale: 0.8,
    })

    TweenLite.set(outline, {
      transformOrigin: '50% 50%'
    })

    TweenLite.set([pauseContainer, pauseGroup, pauseLoopGroup], {
      transformOrigin: '50% 50%',
      scaleY: 0,
      visibility: 'visible'
    })
    TweenLite.set(mainSVG, {
      visibility: 'visible'
    })
  }

  this.showPause = function(){
    mainTl.play('showPause')
  }

  this.setPause = function(){
    mainTl.pause('setPause')
  }

}
