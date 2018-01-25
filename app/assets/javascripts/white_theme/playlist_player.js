function showWaveform() {
  $('.waveform').each(function() {
    var container = $(this);
    var player = $(this).parents('.player');
    var seekbar = player.find('.seekbar');
    var data = waveformData($(this).data('waveform'));
    var soundId = $(this).parent('[data-sound-id]').data('sound-id');
    $(this).removeAttr('data-waveform');

    var soundPosition = 0;
    container.on('update.waveform', function(e, sound) {
      soundPosition = sound.position;
      container.data('waveform').update({ data: data });
    });

    container.data('waveform', new Waveform({
      container: this,
      height: 54,
      innerColor: function(percent, _) {
        if (percent < soundPosition)
          return '#302f2f';
        else
          return '#c7c6c3';
      },
      data: data
    }));

    container.click(function(e) {
      e.preventDefault();

      $('[data-sound-id]').filter(function() {
          return $(this).data('sound-id') != soundId;
      }).find('.pause-button').trigger('click');

      var sound, offx;
      sound = Sound.getSound(soundId);
      offx = e.clientX - container.offset().left;
      sound.setPosition(offx / container.width()).play();
    });

    container.mousemove(function(e) {
      var offx = e.clientX - container.offset().left;
      hoverPosition = offx / container.width();
      seekbar.css('left', offx);
    }).mouseout(function() { hoverPosition = -1 });

    soundManager.onready(function() {
      var sound = Sound.load(player.find('.play-control a').attr('href'));

      sound.playing(function() {
        container.trigger('update.waveform', [this]);
        player.find('.time .index').text(this.index);
      });
    });
  });
}

function mobileHTML5() {
  // Use the same test as soundmanager2
  var ua = navigator.userAgent,
      isAndroid = ua.match(/android/i),
      is_iDevice = ua.match(/(ipad|iphone|ipod)/i);
  return ua.match(/(mobile|pre\/|xoom)/i) || is_iDevice || isAndroid;
}

PlaylistPlayer = {
	elements: $('.tracklist [data-sound-id] a.play-button'),
	tracks: [],
	setup: function(){
    // each page load might have a different play button
    this.largePlayButton = $('.largePlaySVG')
    this.largePlayAnimation = new LargePlayAnimation()
    
	  // this is for the edge case of a playlist with only 1 track
	  if (!this.elements.length)
	    this.elements = $('.play-button a, .pause-button a');

    // sometimes tracks will already be populated
    // for example, a turbolinks:visit
    // if not, we want to load tracks 
    if(!this.tracks.length){
  		this.populateTracks();
  		this.addCallbacksToTracks();
    }

    // we preload the current track if there is one
    this.currentUrl = $('.player .play-control a').attr('href')
	  this.preloadCurrentTrack()
    
    // in every case, we want to set the play button and the waveform
		this.initLargePlayButton();
    showWaveform();
    
    // if something is currently playing, make sure the playlist reflects that
    
	},
  play: function(soundId){
    if(this.shouldLoadNewTrackPage(soundId))
      this.loadNewTrackPage()
    Sound.load(soundId).play()
  },
  pause: function(soundId){
    Sound.pause(soundId)
  },
  shouldLoadNewTrackPage(soundId){
    // if we 
    var currentHref = $('.tracklist > li.active a.play-button').attr('href') 
    var targetHref = $('.tracklist [data-sound-id="'+ soundId + '"] a.play-button').attr('href')
    if(currentHref != targetHref)
      Turbolinks.visit(targetHref)
  },
  loadNewTrackPage(){
    
  },
  preloadCurrentTrack: function(){
    // on the cover view, for example, there's no current track
    if(this.currentUrl)
      Sound.load(this.currentUrl).load();
  },
	populateTracks: function(){
    // creates Sound Manager objects for each html element
	  this.elements.each(function(i) {
	    var url = this.attributes.href.nodeValue;
	    var sound = Sound.load(this.pathname.replace(/(\.mp3)*$/, '.mp3'));
	    sound.element = this;
	   
      sound.positioned(10000, function() {        
	      $.post(url.replace(/\.mp3$/, '') + '/listens');
	    });
      
	    sound.paused(function() {        
	      PlaylistPlayer.changeIconInPlaylistToPlay(this.id);
        PlaylistPlayer.setLargePlayButtonToPlay()
	      window['ga'] && window.ga('send', 'event', 'stream', 'stop', this.id);
	    });
      
      sound.startedPlaying(function(){
        PlaylistPlayer.setLargePlayButtonToPause()
      });
      
      // play is clicked
	    sound.resumed(function() {
	      PlaylistPlayer.changeIconInPlaylistToPause(this.id);
        PlaylistPlayer.animateLargePlayButton();
	      window['ga'] && window.ga('send', 'event', 'stream', 'play', this.id);
	    });

	    sound.finished(function() {
	      PlaylistPlayer.changeIconInPlaylistToPlay(this.id);
	    });
      
	    PlaylistPlayer.tracks.push(sound);
	  });
	},
	addCallbacksToTracks: function(){
    $.each(this.tracks, function(i, sound) {
      var next = PlaylistPlayer[i+1];

      if (mobileHTML5()) {
        sound.finished(function() {
          next && $(next.element).trigger('click');
        });
      } else {
        sound.positioned(-10000, function() {
          next && next.load();
        });

        sound.positioned(-180, function() {
          next && $(next.element).trigger('click');
        });
      }
    });
	},
  initLargePlayButton:function(){
		if (this.largePlayButton.length){
			this.largePlayAnimation.init()
      this.largePlayAnimation.play()
    }
  },
  animateLargePlayButton:function(){
		if (this.largePlayButton.length)
      this.largePlayAnimation.showLoading()
  },
  setLargePlayButtonToPause:function(){
		if (this.largePlayButton.length)
      this.largePlayAnimation.showPause()
  },
  setLargePlayButtonToPlay:function(){
    if (this.largePlayButton.length)
      this.largePlayAnimation.setPlay()
  },
	changeIconInPlaylistToPause:function(soundId){        
		var controls = $('[data-sound-id='+attr(soundId)+'] .play-button,'+
		                 '[data-sound-id='+attr(soundId)+'] .pause-button');
		controls.removeClass('play-button').addClass('pause-button').
		  find('*').andSelf().filter('.fa-play').removeClass('fa-play').addClass('fa-pause');
	},
	changeIconInPlaylistToPlay:function(soundId){
		var controls = $('[data-sound-id='+attr(soundId)+'] .play-button,'+
		                 '[data-sound-id='+attr(soundId)+'] .pause-button');
		controls.removeClass('pause-button').addClass('play-button').
		  find('*').andSelf().filter('.fa-pause').removeClass('fa-pause').addClass('fa-play');
	}
	
};

function attr(val) {
  return val.replace(/\//g, '\\/').replace(/@/g, '\\@');
}

function waveformData(csv) {
  if(csv.length > 1){
    var data = csv.split(',').map(function(s) {
      return parseFloat(s);
  })}else{
    var data = [0,.9,1,.9,1,.9,1,.9,1,.9,1,.9,1,.9,1,.9,1,.9,1,.9,1,.9,1,.9,1,.9,1,.9,1,
      .9,1,.9,1,.9,1,.9,1,.9,1,.9,1,.9,1,.9,1,.9,1,.9,1,.9,1,.9,1,.9,1,.9,1,.9,1,.9,1,.9,1,.9,1,0];
  }

  var max = Math.max.apply(Math, data),
      min = Math.min.apply(Math, data);
  var scale = Math.max(Math.abs(max), Math.abs(min));
  data = data.map(function(s) {
    return (s < 0 ? -1 : 1 ) * Math.pow(Math.abs(s) / scale, 0.7);
  });

  return data;
}

