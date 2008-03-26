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
    this.trackLink = $(".title > a",this.element);
    this.deleteButton = $(".delete-button",this.element);
    this.trackLink = this.trackName.href;
    this.soundID = "play-"+this.trackLink.id;  
  },
  
  
  // Lets Delegate!
  // we want the track to do lots of things onclick, but not add 100s of event handlers
  onclick: $.delegate({
    // so we're going to test the origin element of the click using selectors
    '.' 
  }),
  
  // 
  togglePlay: function(){
    
  },
  
  play: function(){
    
  },
  
  
  
  
})

