//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require soundmanager2
//= require jquery-carousel
//= require jquery-lowpro
//= require facebox
//= require local-time
//= require highlight
//= require upload
//= require turbolinks
//= require soundmanager_setup
//= require lowpro_behaviors
//= require handlers

//= require jquery-fileupload/basic
//= require greenfield/initialize_soundManager
//= require greenfield/resize_textarea
//= require greenfield/file_upload
//= require greenfield/sound
//= require greenfield/waveform
//= require greenfield/posts

//= require white_theme/playlist_player
//= require white_theme/TweenMax.min.js


(function($) {

	document.addEventListener("turbolinks:load", function() {
		
		function FaveAnim() {

		  var xmlns = "http://www.w3.org/2000/svg",
		    xlinkns = "http://www.w3.org/1999/xlink",
		    select = function(s) {
		      return document.querySelector(s);
		    },
		    selectAll = function(s) {
		      return document.querySelectorAll(s);
		    }, 
		    mainSVG = select('.faveSVG'),
		    mainTl, purplePopTl, redPopTl, heartTl, allPopTl, greenPopTl, yellowPopTl, bluePopTl, redPop2Tl, redPop3Tl,
		      redPop3 = select('.redPop3'),
		      redPop2 = select('.redPop2'),
		      bluePop = select('.bluePop'),
		      yellowPop = select('.yellowPop'),
		      purplePop = select('.purplePop'),
		      greenPop = select('.greenPop'),
		      redPop = select('.redPop'),
		      outline = select('.outline'),
		      heart = select('.heart')

		  this.init = function() {
		    TweenMax.set(mainSVG, {
		      visibility: 'visible'
		    })
		    TweenMax.set([outline, heart], {
		      transformOrigin:'50% 50%'
		    })

		    allPopTl = new TimelineMax().timeScale(1);
		   
		    redPop2Tl = new TimelineMax({}).timeScale(1);
		    redPop3Tl = new TimelineMax({}).timeScale(1);
		    bluePopTl = new TimelineMax({}).timeScale(1);
		    yellowPopTl = new TimelineMax({}).timeScale(1);
		    greenPopTl = new TimelineMax({}).timeScale(1);
		    purplePopTl = new TimelineMax({}).timeScale(1);
		    redPopTl = new TimelineMax({}).timeScale(1);
		    heartTl = new TimelineMax({}).timeScale(1);
		    mainTl = new TimelineMax({paused:true}).timeScale(1.6);
		   
		   mainTl.addLabel('clickFave')
		    .to(outline, 0.2, {
		    scale:0.9,
		    ease:Linear.easeNone
		   })
		   .to(outline, 0.2, {
		    scale:1,
		    ease:Linear.easeNone
		   })
		   .set(outline, {
		    autoAlpha:0,
		    scale:0.7
		   },'-=0')
		   .from(heart, 1,{
		    scale:0,
		    fill:'#f638a8',
		    ease:Elastic.easeOut.config(1.5, 0.7)
		    //ease:Anticipate.easeIn
		   },'-=0.34')
		   //.addCallback(function(){allPopTl.play(0)},0.16)
		   
		   .addLabel('setFave')
		  .addPause()
		   .addLabel('clickUnfave')
		/*    .set(outline, {
		    scale:0.7
		   }) */
		   .set(outline, {
		    autoAlpha:1
		   }) 
		   .to(heart, 0.4,{
		     scale:0
		   })
		   .to(heart, 0.1, {
		    fill:'#b4b4b4',
		    stroke:'#b4b4b4'
		   },'-=0.4')      
		   .to(outline, 1, {
		    scale:1,
		    ease:Elastic.easeOut.config(1.5, 0.7)
		   },'-=0.3')
		   .addLabel('setUnfave')
		   //POPS
		   
		   purplePopTl.fromTo(purplePop, 0.4, {
		    attr:{
		     r:0
		    }
		   },{
		    attr:{
		     r:100
		    },
		    ease:Power1.easeOut
		   })
		   .from(purplePop,0.6, {
		    strokeWidth:23,
		    ease:Power3.easeInOut
		   },'-=0.4')
		   .to(purplePop, 0.2, {
		    attr:{
		     r:110
		    },
		    ease:Power3.easeOut
		   },'-=0.2 ')

		 redPopTl.fromTo(redPop, 0.4, {
		    attr:{
		     r:0
		    }
		   },{
		    attr:{
		     r:100
		    },
		    ease:Power1.easeOut
		   })
		   .from(redPop,0.6, {
		    strokeWidth:23,
		    ease:Power3.easeInOut
		   },'-=0.4')
		   .to(redPop, 0.2, {
		    attr:{
		     r:110
		    },
		    ease:Power3.easeOut
		   },'-=0.2 ')


		 greenPopTl.fromTo(greenPop, 0.4, {
		    attr:{
		     r:0
		    }
		   },{
		    attr:{
		     r:100
		    },
		    ease:Power1.easeOut
		   })
		   .from(greenPop,0.6, {
		    strokeWidth:23,
		    ease:Power3.easeInOut
		   },'-=0.4')
		   .to(greenPop, 0.2, {
		    attr:{
		     r:110
		    },
		    ease:Power3.easeOut
		   },'-=0.2 ')
		   
		yellowPopTl.fromTo(yellowPop, 0.4, {
		    attr:{
		     r:0
		    }
		   },{
		    attr:{
		     r:100
		    },
		    ease:Power1.easeOut
		   })
		   .from(yellowPop,0.6, {
		    strokeWidth:23,
		    ease:Power3.easeInOut
		   },'-=0.4')
		   .to(yellowPop, 0.2, {
		    attr:{
		     r:110
		    },
		    ease:Power3.easeOut
		   },'-=0.2 ')

		bluePopTl.fromTo(bluePop, 0.4, {
		    attr:{
		     r:0
		    }
		   },{
		    attr:{
		     r:100
		    },
		    ease:Power1.easeOut
		   })
		   .from(bluePop,0.6, {
		    strokeWidth:23,
		    ease:Power3.easeInOut
		   },'-=0.4')
		   .to(bluePop, 0.2, {
		    attr:{
		     r:110
		    },
		    ease:Power3.easeOut
		   },'-=0.2 ')

		redPop2Tl.fromTo(redPop2, 0.4, {
		    attr:{
		     r:0
		    }
		   },{
		    attr:{
		     r:100
		    },
		    ease:Power1.easeOut
		   })
		   .from(redPop2,0.6, {
		    strokeWidth:23,
		    ease:Power3.easeInOut
		   },'-=0.4')
		   .to(redPop2, 0.2, {
		    attr:{
		     r:110
		    },
		    ease:Power3.easeOut
		   },'-=0.2 ')

		redPop3Tl.fromTo(redPop3, 0.4, {
		    attr:{
		     r:0
		    }
		   },{
		    attr:{
		     r:100
		    },
		    ease:Power1.easeOut
		   })
		   .from(redPop3,0.6, {
		    strokeWidth:23,
		    ease:Power3.easeInOut
		   },'-=0.4')
		   .to(redPop3, 0.2, {
		    attr:{
		     r:110
		    },
		    ease:Power3.easeOut
		   },'-=0.2 ');
		     
		   allPopTl.add(redPopTl)
		   .add(purplePopTl,'-=0.56')
		   .add(yellowPopTl,'-=0.5')
		   .add(bluePopTl,'-=0.55')
		   .add(greenPopTl,'-=0.55')
		   .add(redPop2Tl,'-=0.7')
		   .add(redPop3Tl,'-=0.55')
		//

		   //mainTl.add(heartTl, 0);
		   
		  // console.log(redPopTl)
		   mainTl.add(allPopTl,0.16);
		   
		  }

		/*   this.play = function(pos) {
		   if(pos){mainTl.play(pos);} return;    
		    mainTl.play();
		  }
		  this.pause = function(pos) {
		   if(pos){mainTl.pause(pos);} return;    
		    mainTl.pause();
		  } */
		  this.timeline = function() {
		    return mainTl;
		  }
		  this.clickFave = function() {
		    mainTl.play('clickFave');
		  }
		  this.clickUnfave = function() {
		    mainTl.play('clickUnfave');
		  }
		  this.setFave = function() {
		    mainTl.pause('setFave');
		  }
		  this.setUnfave = function() {
		    mainTl.pause('setUnfave');
		  }
		}

		var myFaveAnim = new FaveAnim();
		myFaveAnim.init();
		//myFaveAnim.play();

		//ScrubGSAPTimeline(myFaveAnim.timeline())

		//simulated usage - REMOVE THIS
		//pauses on the play icon
		/*
		//plays the favourite animation
		TweenMax.delayedCall(1, function(){myFaveAnim.clickFave();})
		//plays unfave animation
		TweenMax.delayedCall(5, function(){myFaveAnim.clickUnfave();}) 
		//sets to be a fave without animation
		TweenMax.delayedCall(8, function(){myFaveAnim.setFave();}) 
		//sets to be an unfave without animation
		TweenMax.delayedCall(12, function(){myFaveAnim.setUnfave();}) 



		*/



		$("a.add_to_favorites").click(function() {


		 if(myFaveAnim.timeline().time() == 0 || myFaveAnim.timeline().time() == myFaveAnim.timeline().duration()){
		  myFaveAnim.clickFave()
		 } else {
		  myFaveAnim.clickUnfave();
		 }
		});

	});

})(jQuery);