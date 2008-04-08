var soundIsReady = false;
soundManager.onload = function() {
  // soundManager is ready to use
  soundIsReady = true;
}

// for debug purposes
$.fn.log = function() {
  if (this.size()==0) return "<em>wrapped set is empty</em>"
  var text = '';
  this.each(function(){
    text += this.tagName;
    if (this.id) text += '#' + this.id;
  });
}

// hack up a periodical executor
jQuery.timer = function (interval, callback)
 {
	var interval = interval || 100;

	if (!callback)
		return false;
	
	_timer = function (interval, callback) {
		this.stop = function () {
			clearInterval(self.id);
		};
		
		this.internalCallback = function () {
			callback(self);
		};
		
		this.reset = function (val) {
			if (self.id)
				clearInterval(self.id);
			
			var val = val || 100;
			this.id = setInterval(this.internalCallback, val);
		};
		
		this.interval = interval;
		this.id = setInterval(this.internalCallback, this.interval);
		
		var self = this;
	};
	
	return new _timer(interval, callback);
};

jQuery.easing.def = "jswing"

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




// TRACKS

/* Most of the code here is taking advantage of 2 main concepts by dan webb.

Event Delegation, which exponentially reduces the amount of event listeners by relying on bubbling
http://www.danwebb.net/2008/2/8/event-delegation-made-easy-in-jquery

Inheritable Behaviours, which allows one to build componentized behaviours that are inheritable

Both are baked into lowpro

DateSelector = $.klass({
  onclick: $.delegate({
    '.close': function() { this.close() },
   '.day': function(e) { this.selectDate(e) }
  }),
  selectDate: function(dayElement) {
    // code ...
  },
  close: function() {
    // code ...
  }
});

*/

SlideOpenNext = $.klass({
  initialize:function(){
    this.next = this.element.next();
  },
  onclick:function(){
    this.next.slideToggle();
    return false;
  }
  
});

AdjustableTextarea = $.klass({
  
  initialize : function(line_height){
    this.line_height = line_height;
    this.character_width = this.element.attr('cols');
  },
  checkForSizeChange : function(){
    if(this.collapsed_height_in_px == undefined) this.set_collapsed_height();
    lines = this.element.val().split("\n");
    actual_row_count = lines.length;
    for(line in actual_row_count){
      actual_row_count += parseInt(line.length / this.character_width);
    }
    if(this.starting_row_count < actual_row_count)
      this.element.css({height:(this.collapsed_height_in_px*2)+'px'});
    else
      this.element.css({height:this.collapsed_height_in_px+'px'});
    
  },
  onkeypress: function(){
    this.checkForSizeChange();
  },  
  oninput: function(){
    this.checkForSizeChange();
  },  
  onpaste: function(){
    this.checkForSizeChange();
  },
  set_collapsed_height: function(){
    // done here, because at first textarea may be hidden
    this.collapsed_height_in_px = this.element.height();
    this.starting_row_count = parseInt(this.collapsed_height_in_px / this.line_height);
  }

});

// abstracts ui.tabs a bit further   
Tabbies = $.klass({
  initialize : function(desiredTab){
    this.defaultTab = 0;
    this.element.tabs({ fx: [null,{ height: 'toggle',duration: 300,easing:'easeOut'}, ], selected: (desiredTab || this.defaultTab) });
    this.currentTab = 0;
  },
  openTab : function(desiredTab){
    desiredTab = desiredTab || this.defaultTab;
    this.element.tabs('select', desiredTab);
    this.currentTab = desiredTab;
  }
});

CommentForm = $.klass(Remote.Form, {
    initialize : function(options) {
      this.submitButton = $('.comment_submit', this.element);
      this.submitText = this.submitButton.val();
      this.spinner = $('.small_spinner',this.element);
      this.resultBox = $('.comment_waiting', this.element);
      this.textarea = $('textarea', this.element);
      this.options = $.extend({
        beforeSend: $.bind(this.send,this),
        success: $.bind(this.success, this),
        error: $.bind(this.error, this),
        complete: $.bind(this.complete, this)
      }, options || {});
    },
    send:function(){
      this.spinner.show();
      this.disable();
    },
    complete:function(){
      this.spinner.hide();
      this.enable();
    },
    disable:function(){
      this.submitButton.attr('disabled','disabled');
      this.submitButton.val('sending comment...');
    },
    enable:function(){
      this.submitButton.removeAttr('disabled');
      this.submitButton.val(this.submitText);
    },
    success:function(){
      this.resultBox.text('Submitted, thanks!')
      this.resultBox.fadeIn(100);
      this.textarea.val('');
      this.spinner.hide();
    },
    error: function(){
      this.resultBox.text("Didn't work, try again?")
      this.resultBox.fadeIn(100);
    }
});

Track = $.klass({  
  initialize: function() {
    this.playButton = $(".play-button",this.element);
    this.trackLink = $("a.track_link",this.element);
    this.time = $('span.counter',this.element);
    this.deleteButton = $(".delete-button",this.element);
    this.trackURL = $('a.play_link',this.element).attr('href');
    this.soundID = 'play-'+this.element[0].id; 
    this.more = this.element.next();
    this.tabbies = false; // wait on initializing those tabs
  },
  
  
  // Lets Delegate!
  // we want the track to do lots of things onclick, but not add 100s of event handlers
  // so test the origin element of the click using selectors
  onclick: $.delegate({
    '.play_link' : function(e){ return this.togglePlay()},      // open comments
    '.track_link': function(e){ return this.toggleDetails(1)}, // open info
    '.download_link':function(e){ return this.toggleDetails(2)}, // open sharing
    '.title':function(e){ return this.toggleDetails(1)} // open 
  }),
  
  onmouseenter: $.delegate({
    '.asset' : function(e){  this.element.addClass('hover');}
  }),
  
  onmouseleave: $.delegate({
    '.asset' : function(e){  this.element.removeClass('hover');}
  }),
  
  toggleDetails: function(desiredTab){
    if(this.more.is(':hidden')) this.openDetails(desiredTab);
    else if (this.isPlaying()) this.openDetails(desiredTab); // never close the tabs when playing
    else this.closeDetails();
    return false;
  },
  
  openDetails: function(desiredTab){
    // set up the tabs if this track hasn't been opened yet
    if(!this.tabbies) this.createTabbies();
    
    // change the tab if the desired is not currently open
    if(this.tabbies.currentTab != desiredTab) this.tabbies.openTab(desiredTab);
    
    // open the pane if it is not already open
    if(this.isOpen != false) this.more.slideDown({duration:300,queue:false});
    
    // close all other detail panes except currently playing
    for(var track in Track.instances){
        if(!Track.instances[track].isPlaying() && this.element != Track.instances[track].element) 
          Track.instances[track].closeDetails();
    }
    
    this.element.addClass('open');
  },
  
  closeDetails:function(){
    this.more.slideUp({duration:300,queue:false});
    this.element.removeClass('open');
  },
  
  isOpen:function(){
    this.more.is(':visible');
  },
  
  togglePlay: function(target){ 
    if(this.isPlaying()) 
      this.pause();
    else
      this.playOrResume();
    // don't follow the link
    return false;
  },
  
  playOrResume : function(){
    this.killOtherTracks();
    this.element.addClass('playing');
    this.openDetails(0);
    this.ensureSoundIsReadyThenPlay();
  },
  
  tellSoundManagerToPlay: function(){
    this.startTimer();
    if (this.isPaused()){
      this.resume();
    }else{
      this.play();
    }
  },
  
  play: function(){
    onFinishCallback = $.bind(this.startNextTrack,this);
    soundManager.play(this.soundID,{url: this.trackURL, onfinish:$.bind(this.startNextTrack,this)});
  }, 
  
  isPlaying: function(){
    return this.element.hasClass('playing');
  },
  
  pause: function(){
    soundManager.pause(this.soundID);
    this.element.removeClass('playing');
    this.closeDetails();
  },
  
  isPaused: function(){
    if(this.soundIsLoaded()) return true;
    else return false;
  },
  
  soundIsLoaded: function(){
    if (soundManager.soundIDs.length > 0 && ($.inArray(this.soundID,soundManager.soundIDs) != -1)) return true;
    else return false;
  },
  
  resume: function(){
    soundManager.resume(this.soundID);
  },
  
  startNextTrack: function(){
    this.pause();
    Track.instances[this.nextTrackIndex()].playOrResume();
    console.log('starting next track');
  },
  
  nextTrackIndex : function(){
    // index of next Track in Track.instances
    var next = Track.instances.indexOf(this) + 1;
    // loop back to the first track
    if(Track.instances[next] == undefined) next = 0;
    return next;
  },
  
  killOtherTracks : function(){
    for(var track in Track.instances){ 
      if(Track.instances[track].isPlaying()) Track.instances[track].pause();
    }
  },
  
  createTabbies : function(){
    this.tabbies = $('ul',this.more).attachAndReturn(Tabbies)[0]; // low pro returns an array
    this.commentForm = $('.comment_form form',this.more).attachAndReturn(CommentForm)[0];
  },
  startTimer : function(){
    $.timer(1000,$.bind(this.updateTime,this));
  },
  updateTime : function(){
    this.sound = soundManager.getSoundById(this.soundID);
    if(this.sound != undefined){
      this.elapsed_time = Math.round(this.sound.position / 1000);
      seconds = this.elapsed_time % 60;
      if(seconds < 10) seconds = '0'+seconds; // aww, i miss prototype
      this.time.html(Math.floor(this.elapsed_time/60) + ':' + seconds);
    }
  },
  ensureSoundIsReadyThenPlay : function(){
    if(soundIsReady) return this.tellSoundManagerToPlay();
    tryAgain = $.bind(this.ensureSoundIsReadyThenPlay, this); // use lowpro bind to create closure
    setTimeout('tryAgain()','300');
  }
});

jQuery(function($) {
  // Tracks 
  $('.asset, .track').attach(Track);
  
  // Slide open the next element on click
  $('.slide_open_next').attach(SlideOpenNext);
  
  // double the text area size when typing a lot
  $('textarea.double_trouble').attach(AdjustableTextarea,16);
  
});

