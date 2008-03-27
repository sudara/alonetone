// for debug purposes
$.fn.log = function() {
  if (this.size()==0) return "<em>wrapped set is empty</em>"
  var text = '';
  this.each(function(){
    text += this.tagName;
    if (this.id) text += '#' + this.id;
  });
  console.log(text);
}

// png fix if ie
$(function(){$(document).pngFix();});


// front page carousel
$(function() {
    $(".playlists_carousel").jCarouselLite({
        btnNext: ".next",
        btnPrev: ".prev",
        visible: 4,
        scroll: 4,
        circular: false
    });
});

// tabs
$(document).ready(function(){
  $('.tabs > ul').tabs({ fx: { height: 'toggle'} });
});


// TRACKS

/* Most of the code here is taking advantage of 2 main concepts by dan webb.

Event Delegation, which exponentially reduces the amount of event listeners by relying on bubbling
http://www.danwebb.net/2008/2/8/event-delegation-made-easy-in-jquery

Inheritable Behaviours, which allows one to build componentized behaviours that are inheritable

Both are baked into lowpro

DateSelector = $.klass({
  onclick: $.delegate({
    '.close': function() { this.close() },
   '.day': function(e) { this.selectDate(e.target) }
  }),
  selectDate: function(dayElement) {
    // code ...
  },
  close: function() {
    // code ...
  }
});

*/


Track = $.klass({
  
  initialize: function() {
    this.playButton = $(".play-button",this.element);
    this.trackLink = $("a.track_link",this.element);
    this.deleteButton = $(".delete-button",this.element);
    this.trackURL = this.trackLink.attr('href');
    this.soundID = "play-"+this.trackLink.id; 
  },
  
  
  // Lets Delegate!
  // we want the track to do lots of things onclick, but not add 100s of event handlers
  onclick: $.delegate({
    // test the origin element of the click using selectors
    '.play-button a' : function(e){ return this.togglePlay(e);} 
  }),
  
  onmouseover: $.delegate({
    '.asset' : function(e){ return this.element.addClass('hover');}
  }),
  
  onmouseleave: $.delegate({
    '.asset' : function(e){ return this.element.removeClass('hover');}
  }),
  
  toggleOptions: function(){
    
  },
  
  togglePlay: function(target){
    target.log();
    
    if(this.isPlaying()) 
      this.pause();
    else
      this.playOrResume();
  },
  
  playOrResume : function(){
    this.killOtherTracks();
    this.element.addClass('playing');
    // if the track has already been played
    if (this.isPlaying()){
      this.resume();
    }else{
      this.play();
    }
  },
  
  play: function(){
    soundManager.play(this.soundID,{url:this.trackUrl,onfinish:this.startNextTrack().bind(this)});
  }, 
  
  isPlaying: function(){
    return this.element.hasClass('playing');
  },
  
  pause: function(){
    soundManager.pause(this.soundID);
    this.element.removeClass('playing');
  },
  
  isPaused: function(){
    return soundManager.soundIDs.include(this.soundID);
  },
  
  resume: function(){
    soundManager.resume(this.soundID);
  },
  
  startNextTrack: function(){
    Track.instances[this.nextTrackIndex()].playOrResume();
  },
  
  nextTrackIndex : function(){
    // index of next Track in Track.instances
    var next = Track.instances.indexOf(this) + 1;
    // loop back to the first track
    if(Track.instances[next] == undefined) next = 0;
    return next;
  },
  
  killOtherTracks : function(){
    $.each(Track.instances, function(n,track){ track.pause();});    
  }
});

jQuery(function($) {
  $('.asset, .track').attach(Track);
});

