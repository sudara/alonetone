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
  return text;
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






SortablePlaylist = $.klass({
  initialize : function(){
    this.tracks = $('.tracks', this.element);
    this.sortURL = $('#sort_tracks_url').attr('href');
    this.addTrackURL = $('#add_track_url').attr('href');
    this.emptyWarning = $('.empty',this.element);
    this.create_sortable();   
    this.element.droppable({
      accept: ".asset",
      drop: $.bind(this.add_track, this), // LOVE danwebb and $.bind
      hoverClass: 'adding',
      tolerance: 'touch',
      // change the text to reflect which track
      over: function(e, ui){ $('#drop_here').html('Drop to add "' +($('.track_link',ui.draggable).html()) + '"')}
    });
  },
  serialize_and_post : function(){
    $.post(this.sortURL,$.param({'authenticity_token':window.authenticityToken})+'&'+this.sortable_tracks.sortable('serialize') );
  },
  add_track : function (e,ui){
    $.post(this.addTrackURL, $.param({'asset_id':ui.draggable.attr('id'), 'authenticity_token':window.authenticityToken}),$.bind(this.insert_track,this));
    
  },
  // does the work of inserting the new track and recreating the sortable
  insert_track: function(new_track_html){
    $('#drop_here').before(new_track_html);
    if(this.sortable_tracks != undefined) 
      this.sortable_tracks.sortable('refresh');
    else
      this.create_sortable();
  },
  // catch all delete/remove calls
  onclick: $.delegate({
    'a.delete' : function(e){ return this.remove_track(e.target)}
  }),  
  onmouseover:$.delegate({
    '.asset':function(e){ $(e).css({cursor:'move'})}
  }),
  
  // delete track and remove on success
  remove_track: function(target){
    $(target).html('wait...').parents('.asset').addClass('hover');
    // delete track and remove on success
    $.get($(target).attr('href'),$.bind(this.fade_out,target));
    return false;
  },
  fade_out: function(){
    $(this).parents('.asset').slideUp().remove();
  },
  create_sortable: function(){
    if($('.asset',this.tracks).size() > 1){
     this.sortable_tracks = this.tracks.sortable({
      items: '.asset',
      revert:true,
      containment:'.tracks',
      scroll: true,
      cursor: 'move',
      scrollSensitivity: 100,
      update: $.bind(this.serialize_and_post, this)
    });
    if(this.emptyWarning) this.emptyWarning.slideUp();
    }
  }
  
});

PlaylistSource = $.klass({
  onclick: $.delegate({
    '.pagination a' : function(e){
        $(e.target).parents('.playlist_source').load(e.target.href);
        return false;
    }
  })
  
});
ResizeableFooter = $.klass({
  initialize:function(){
    this.next = this.element.next();
    this.originalHeight = 0;
    this.opened = false;
    this.form = $('#bug_form',this.next);
  },
  onclick: $.delegate({
    '.feedback' : function(e){ return this.toggleFooter()}
    }),
  
  toggleFooter:function (){
    this.opened ? this.close() : this.open();
    return false;
  },
  
  close: function(){
   // this.form.fadeOut(10);
    this.next.animate({
      opacity: 0.6,
      height: this.originalHeight+'px'
    },500,'jswing');   
    this.opened = false;
  },
  
  open: function(){
    this.next.show();
    this.next.css({opacity:0.999});
    this.next.animate({
      height: "300px"
    },600,'easeOutQuad');
    this.form.show();
    this.form.animate({
      opacity: 0.999
    },1200,'jswing'); 
    $('.feedback',this.form).click($.bind(this.close,this))
    
    $('#new_user_report',this.form).attach(CommentForm);
    this.opened = true;
    
  }
  
});

SlideOpenNext = $.klass({
  initialize:function(){
    this.next = this.element.next();
  },
  onclick:function(){
    this.next.slideToggle();
    return false;
  }
  
});

/* rails friendly "delete" (does not degrade!)
DeleteLink = $.klass({
    onclick: function() {
    var options = $.extend({ url: this.element.attr('href'), type: 'POST', data: }, this.options);
    return this._makeRequest(options);
  }
});
*/
// text area that grows 2x in size upon need
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
    initialize : function($super,options) {
      this.submitButton = $('.comment_submit', this.element);
      this.submitText = this.submitButton.val();
      this.spinner = $('.small_spinner',this.element);
      this.resultBox = $('.comment_waiting', this.element);
      this.textarea = $('textarea', this.element);
      $super();
    },
    beforeSend:function(){
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
      this.resultBox.text("Didn't work. Try again?")
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
    this.originalDocumentTitle = document.title; // for prepending when playing tracks
    
    // dont allow tab details to be opened on editing playlists
    this.allowDetailsOpen = (this.element.hasClass('unopenable')) ? false : true;
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
    // don't allow this to happen when editing playlist
    if(!this.allowDetailsOpen) return false;
    
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
    if(!this.allowDetailsOpen) return false;
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
      var time = Math.floor(this.elapsed_time/60) + ':' + seconds;
      this.time.html(time); 
      document.title = '('+time+') '+this.originalDocumentTitle;
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
  
  $('a.confirm_before_delete').click(function(){
    result = confirm('Are you sure?');
    return result;
  });
  
  // double the text area size when typing a lot
  $('textarea.double_trouble').attach(AdjustableTextarea,16);
  
  // slide open the search
  $('#search_button').click(function(){
    $(this).addClass('active');
    $(this).next().width('0px');
    $(this).next().animate({
      width: '200px'
    });
    $(this).next().focus();
    return false;
  });
  
  // setup the footer
  $('#footer').attach(ResizeableFooter);
  
  //$('#edit_playlist .draggable_tracks .track').attach(DraggableTracks);
  $('#edit_playlist .playlist').attach(SortablePlaylist);
  
  // let folks drag tracks to their playlist
  $('#playlist_sources .asset').draggable({
    revert:true,
    //helper:'clone',
    cursor:'move',
    snap: true,
    zindex: 40
  });
  
  // ability to tab through various track sources
  $('#playlist_sources ul#playlist_source_options').attach(Tabbies);
  
  $('#playlist_sources').attach(PlaylistSource);

});


