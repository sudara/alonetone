/* listen! */
soundManager.url = '/javascripts/soundmanager2.swf';

/* cookie extension */

var Cookie = {
	set: function(name,value,seconds){
		if(seconds){
			d = new Date();
			d.setTime(d.getTime() + (seconds * 1000));
			expiry = '; expires=' + d.toGMTString();
		}else
			expiry = '';
		  document.cookie = name + "=" + value + expiry + "; path=/";
	},
	get: function(name){
		nameEQ = name + "=";
		ca = document.cookie.split(';');
		for(i = 0; i < ca.length; i++){
			c = ca[i];
			while(c.charAt(0) == ' ')
				c = c.substring(1,c.length);
			if(c.indexOf(nameEQ) == 0)
				return c.substring(nameEQ.length,c.length);
		}
		return null
	},
	unset: function(name){
		Cookie.set(name,'',-1);
	}
}



Asset = {
  upload: function(form) {
    form = $(form);
    article_id   = location.href.match(/\/edit\/([0-9]+)/);
    form.action  = Mephisto.root + "/admin/articles/upload"
    if(article_id) form.action += "/" + article_id[1]
    form.submit();
  },
  
  addInput: function() {
    var list = $('filefields');
    newNode = list.down().cloneNode(true);
    list.insert(newNode, { position: 'bottom' });
    list.descendants().last().clear();
    Event.addBehavior.reload();
  }
}


/*-------------------- Flash ------------------------------*/
// From Mephisto...
//
var Flash = {
  // When given an flash message, wrap it in a list 
  // and show it on the screen.  This message will auto-hide 
  // after a specified amount of milliseconds
  show: function(flashType, message) {
    new Effect.ScrollTo('flash-' + flashType);
    $('flash-' + flashType).down('p').innerHTML = '';
    $('flash-' + flashType).down('p').innerHTML = message;
    $('flash-'+flashType).show();
    new Effect.Appear('flash', {duration: 0.3});
    Event.observe('flash', 'click', (Flash['fade' + flashType[0].toUpperCase() + flashType.slice(1, flashType.length)]).bindAsEventListener(this));
    setTimeout(Flash['fade' + flashType[0].toUpperCase() + flashType.slice(1, flashType.length)].bind(this), 10000)
  },
  
  
  error: function(message) {
    this.show('flash-error', message);
  },

  info: function(message) {
    this.show('flash-notice', message);
  },
  ok: function(message) {
    this.show('flash-ok', message);
  },
  
  fadeOk:function(){
    $('flash').fade({duration: 0.5,queue:'end'});
    $('flash-ok').fade({queue:'end'});
  },
  
  fadeInfo: function() {
    $('flash').fade({duration: 1.5, queue:'end'});
    $('flash-info').fade({queue:'end'});
  },
  fadeError: function() {
    $('flash').fade({duration: 1.5, queue:'end'});
    $('flash-error').fade({queue:'end'}); 
  }
 
}

var ArticleForm = {
  saveDraft: function() {
    var isDraft = $F(this);
    if(isDraft) ['publish-date-lbl', 'publish-date'].each(Element.hide);
    else ['publish-date-lbl', 'publish-date'].each(Element.show);
  },

  getAvailableComments: function() {
    return $$('ul.commentlist li').reject(function(div) { return !(div.visible() && !div.hasClassName('disabled') && div.id.match(/^comment-/)); }).collect(function(div) { return div.id.match(/comment-(\d+)/)[1] });
  },
  
  getRevision: function() {
    var rev = $F(this)
    var url = Mephisto.root + '/admin/articles/edit/' + location.href.match(/\/edit\/([0-9]+)/)[1];
    if(rev != '0') url += "/" + rev;
    location.href = url;
  }
}

Comments = {
  filter: function() {
    location.href = "?filter=" + $F(this).toLowerCase();
  }
}

var UserForm = {
  toggle: function(chk) {
    $('user-' + chk.getAttribute('value') + '-progress').show();
    new Ajax.Request(Mephisto.root + '/admin/users/' + (chk.checked ? 'enable' : 'destroy') + '/' + chk.getAttribute('value'));
  },
  toggleAdmin: function(chk) {
    $('user-' + chk.getAttribute('value') + '-progress').show();
    new Ajax.Request(Mephisto.root + '/admin/users/admin/' + chk.getAttribute('value'));
  }
}


var Bright = { root: '' };

// Template for ActsAsLink
var ActsAsLink = Behavior.create({
  onmousedown : function(){
    this.element.addClassName('down')
  },
  onmouseup    : function(){
    this.element.removeClassName('down')
  },
	onmouseenter : function(){
		this.element.setStyle({cursor:'pointer'});
		this.element.addClassName('over');
	},
	onmouseleave : function(){
		this.element.setStyle({cursor:'default'});		
		this.element.removeClassName('over');
	}
});


var Volume = {
	default_volume : 0.7,
	initialize : function(){
		this.level = Cookie.get('alonetone_volume');
		if(this.level == null) this.level = this.default_volume;
		this.set(this.level);
	},
	set : function(value){
		$('volume_level').morph({width:((value*195)+10)+'px'});
	  Cookie.set('alonetone_volume',value);
    soundManager.defaultOptions.volume = (value*100).toFixed();
		soundManager.soundIDs.each( function(s) {
   		soundManager.setVolume(s, (value*100).toFixed())
  	});
	}		
}

// SOUND MANAGER
var BigPlayButton = Behavior.create(ActsAsLink,{
	initialize : function(){
		// let the spacebar have the same functionality
		//Event.observe(document, 'keydown', this.spacebar.bindAsEventListener(this));
		this.lastPaused = false
	},
	spacebar: function(event){
		if(event.keyCode == 32 && !Event.element(event).descendantOf('form')){
			Event.stop(event);
			this.onclick();
		}
	},
	onclick : function(){
		// if nothing is playing or has been played, start the first track
		if(soundManager.soundIDs.size() < 1){
		  // play the first track
			Track.instances.first().playOrResume();
			this.play();
			return;
		}
		// if a track is paused, start it
		if(this.lastPaused != false && !this.element.hasClassName('playing')){
			this.lastPaused.playOrResume();
			this.play();
			return;
		}
		// if a track is playing, pause it
		Track.instances.each(function(track){
			if(soundManager.sounds[track.soundID] && soundManager.sounds[track.soundID].playState == 1){
        track.pause();
        this.pause();
        this.lastPaused = track;
        return;
			}
		}, this);

	},
	play : function(){
	  this.element.addClassName('playing');
	  this.element.removeClassName('paused');
	  this.playing = true;
	},
	pause : function(){
	  this.element.removeClassName('playing');
	  this.element.addClassName('paused');
	  this.playing = false;
	}

});

var Playlist = Behavior.create({
  initialize : function(){
    if(this.hasEditAbility == true){
      this.info = this.element.down('.info');
      this.edit = this.info.down('.edit_playlist');
      Element.observe(this.info,'mouseenter',this.showEditButton.bindAsEventListener(this));
      Element.observe(this.info,'mouseleave',this.hideEditButton.bindAsEventListener(this));  
    }
  },
  
  showEditButton : function(event){
    this.edit.appear();
  },
  hideEditButton : function(event){
    this.edit.fade();
  },
  hasEditAbility : function(){
    if(!this.element.down('.info').isUndefined) return true;
  }

});

var Track = Behavior.create({
  
  initialize : function(options){
    
    this.track = this.element;
    this.playButton = this.element.down('.play-button');
    this.deleteButton = this.element.down('.delete-button');
    this.editButton = this.element.down('.edit');
    this.move = this.element.down('.move');
    this.share = this.element.down('.share');
    this.drag = this.element.down('.drag');
    this.time = this.element.down('.time');
    this.commentButton = this.element.down('.comment-button');
    this.elapsed
    
    // where we are in the track in seconds
    this.elapsed_time = 0;
    
    // setup our timer
    this.timer = false;
    
    // 'compact' removes any undefined elements from the array
    this.extras = [this.share, this.editButton, this.deleteButton, this.move, this.commentButton, this.drag].compact();
    
    this.trackName = this.element.down('.title').down('a');
    this.trackUrl = this.trackName.href;
    this.soundID = "play-"+this.trackName.id;
    
    // this just conviniently adds/removes 'over' class names and mouse pointers
    new ActsAsLink(this.track);
    new ActsAsLink(this.playButton);
    if(this.move != undefined) new ActsAsLink(this.move);
    if(this.deleteButton != undefined) new ActsAsLink(this.deleteButton);
    
    Event.observe(this.track, 'mouseenter', this.showExtras.bindAsEventListener(this));
    Event.observe(this.track, 'mouseleave', this.hideExtras.bindAsEventListener(this));
    
    Event.observe(this.trackName, 'click', this.togglePlay.bindAsEventListener(this));
    Event.observe(this.playButton, 'click', this.togglePlay.bindAsEventListener(this));

  },
  updateTime : function(){
    this.sound = soundManager.getSoundById(this.soundID);
    if(this.sound != undefined && this.time != undefined && this.timer != false){
      this.elapsed_time = (this.sound.position / 1000).round();
      this.time.innerHTML =  (this.elapsed_time/60).floor() + ':' + (this.elapsed_time % 60).toPaddedString(2);
    }
  },
  nextTrackIndex : function(){
    // index of next Track in Track.instances
    var next = Track.instances.indexOf(this) + 1;
    // loop back to the first track
    if(Track.instances[next] == undefined) next = 0;
    return next;
  },

  showExtras : function(){
    this.extras.invoke('show');
  },  
  hideExtras : function(){
    this.extras.without(this.share).invoke('hide');
    if(!this.track.hasClassName('playing') && this.share != undefined) this.share.hide();
  },
  
  togglePlay : function(event){
    if(this.track.hasClassName('playing')) 
      this.pause();
    else
      this.playOrResume();
    // make sure event doesn't click through
    Event.stop(event);
  },
  restartTrack : function(){
    soundManager.play(this.soundID, this.trackUrl);
  },
  startNextTrack : function(){
    Track.instances[this.nextTrackIndex()].playOrResume();
  },
  
  playOrResume : function(){
    // kill any other playing tracks
    Track.instances.invoke('pause');    
    this.track.addClassName('playing');
    if(this.share != undefined) this.share.show();
    // if the track has already been played
    if (soundManager.soundIDs.include(this.soundID)){
      this.resume();
    }else{
      this.play();
    }
  },
  pause : function(){
    soundManager.pause(this.soundID);
    this.track.removeClassName('playing');
    BigPlayButton.instances.first().pause();
    BigPlayButton.instances.first().lastPlayed = this;
    if(this.timer) this.timer.stop();
  },
  play : function(){
    soundManager.play(this.soundID,{url:this.trackUrl,onfinish:this.startNextTrack.bind(this)});
    BigPlayButton.instances.first().play();
    this.setupTimer();
  },
  resume : function(){
    soundManager.resume(this.soundID);
    BigPlayButton.instances.first().play();
    this.setupTimer();
  },
  setupTimer :function(){
    this.timer = new PeriodicalExecuter(this.updateTime.bind(this), 1);
  }
  
});

Effect.DefaultOptions.duration = 0.80;
Event.addBehavior.reassignAfterAjax = true;
Event.addBehavior({

  '#reset_password': function() { this.hide(); },
  '#reset_password_link:click,#reset_password_cancel:click': function() { Effect.toggle('reset_password', 'blind'); },
  '#asset-add-file:click': function() { return Asset.addInput(); },
  '#sec-options-trigger:click': function() { $('sec-options').toggle(); },
  '#disabled_users_trigger:click': function() { $('disabled_users').toggle(); },

  '#article-search': function() {
    new SmartSearch('article-search', [
      {keys: ['section'],               show: ['sectionlist'],  hide: ['manualsearch', 'searchsubmit']},
      {keys: ['title', 'body', 'tags'], show: ['manualsearch'], hide: ['sectionlist', 'searchsubmit']},
      {keys: ['draft'],                 show: ['searchsubmit'], hide: ['manualsearch', 'sectionlist']}
    ], 'sectionlist')
  },

	'#upload:click': function(){
		$('uploading').toggle
	},
	
	
	// Playlists
	
	// when tracks are wrapped in a div.draggable tracks, they are draggable
	'div.draggable_tracks div.asset':function(){
		new Draggable(this,{dropOnEmpty:true,revert:true,constraint:false});
		this.addClassName('draggable');
	},
	
	// Big Play Button & space bar
	'#play':BigPlayButton,
  
  // show an edit on hover
  '.playlist' :Playlist,
  
  // fancy tracks
  'li.track' : Track,
  'div.track' : Track,
	'div.asset' : Track,
	
	// PLAYLISTS  
	'a#open_your_stuff:click' : function(event){
	  $$('.playlist_source').invoke('hide');
	  $('your_stuff_box').slideDown();
	  $('search_box').hide();  
    this.siblings().invoke('removeClassName','active');
    this.addClassName('active');
    Event.stop(event);
	},
	'a#open_your_listens:click':function(event){
	  $$('.playlist_source').invoke('hide');
	  $('your_listens_box').slideDown();
	  $('search_box').hide(); 
	  this.siblings().invoke('removeClassName','active');
    this.addClassName('active');
    Event.stop(event);
	},
	'a#open_search:click':function(event){
		$$('.playlist_source').invoke('hide');
	  $('search_box').show();  
	  $('search_alonetone').slideDown();
	  this.siblings().invoke('removeClassName','active');
    this.addClassName('active');
    Event.stop(event);

	},
	
	// pagination, when it exists is done via ajax
  'div.pagination a' : Remote.Link,
	
	/* user list zoom
	'#user-index .user:mouseenter' : function(){
	  this.down().down('img').morph({width:'200px',height:'200px',position:'absolute', clear:'none'},{duration:0.3, queue:'parallel'});
	  this.down('.details').appear({duration:0.3,queue:'parallel'});
	  this.down('.name').morph('width:195px',{duration:0.3,queue:'parallel'});
	  
	},
	'#user-index .user:mouseleave' : function(){
	  this.down().down('img').morph({width:'100px',height:'100px',position:'relative'},{duration:0.3,queue:'parallel'});
	  this.down('.details').fade({duration:0.3,queue:'parallel'});
	  this.down('.name').morph('width:95px',{duration:0.3,queue:'parallel'});

	},*/
	
	// footer
	'a.feedback:click' : function(){
	  $('footer').morph({height:'300px'});
    $('bug-form').appear({duration:1.0});
	},
	'a#nevermind:click' : function(){
	  $('bug-form').fade({duration:0.5});
	  $('footer').morph({height:'40px'});
	},
	
	// Show 'OMG this is going to take time' when >3 assets or zip file
	'input.asset_data:change' : function(){
	  // did they choose a zip?
	  if($F(this).endsWith('.zip') || this.up('li').adjacent('li').size() > 1){
	    $('relax').show();
	  }
	},
	
	// share footer
	'.share a:click' : function(event){	  
    // target an element like 'share_asset_40'
    toShare = $('share_' + this.up().up().identify().gsub(/(track_|asset_|playlist_)/,''));
    if(toShare != undefined){
  	  $('share').childElements().invoke('hide');
  	  toShare.show();
  	  $('footer').morph({height:'300px'});
  	}
  	Event.stop(event);
  	},
	'#share a.done:click' : function(event){
	  this.up('.footer_content').fade();
	  $('footer').morph({height:'40px'});
	  Event.stop(event);
	},

	// comment footer
	'.comment-button a:click' :function(event){
	    commentBox = $('comment_' + this.up().up().up().identify().gsub(/(track_|asset_|playlist_)/,''));
	    if(commentBox != undefined){
  	    $('share').childElements().invoke('hide');
  	    commentBox.show();
  	    $('footer').morph({height:'200px'});
  	  }
    	Event.stop(event);
	}

});


Event.onReady(function() {
  // if any flashes already exist, show them
  // each flash type
  ['info', 'error', 'ok'].each(function(flashType) {
    var el = $('flash-' + flashType);
    // actual messages live inside #flash #flash-type p
    if(el.down('p').innerHTML != '') Flash.show(flashType, el.down('p').innerHTML);
  });
  

	Volume.initialize();
	var volumeSlider = new Control.Slider('volume_handle','volume_track',{sliderValue: Volume.level});
	volumeSlider.options.onSlide = function(value){
		 Volume.set(value);
	}

	volumeSlider.options.onChange = function(value){
		Volume.set(value);
	}
    
});

