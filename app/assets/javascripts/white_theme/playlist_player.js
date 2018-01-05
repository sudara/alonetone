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
      console.log('WOO loading ' + player.find('.play-control a').attr('href'))
      var sound = Sound.load(player.find('.play-control a').attr('href'));

      sound.playing(function() {
        // display pause button
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

Playlist = {
	elements: $('.tracklist [data-sound-id] a.play-button'),
	tracks: [],
	currentTrack: $('.player .play-control a').attr('href'),
	setup: function(){
	  // this is for the edge case of a single-track playlist
	  if (!this.elements.length)
	    this.elements = $('.play-button a, .pause-button a');
		this.populateTracks();
		this.addCallbacksToTracks();
	  if (this.currentTrack)
	    Sound.load(this.currentTrack).load();
	},
	populateTracks: function(){
	  this.elements.each(function(i) {
	    var url = this.attributes.href.nodeValue;
	    var sound = Sound.load(this.pathname.replace(/(\.mp3)*$/, '.mp3'));
	    Playlist.tracks.push(sound);

	    sound.ui = this;

	    sound.positioned(10000, function() {
	      $.post(url.replace(/\.mp3$/, '') + '/listens');
	    });

	    sound.paused(function() {
	      Playlist.changeIconInPlaylistToPause(this.id);
	      window['ga'] && window.ga('send', 'event', 'stream', 'stop', this.id);
	    });

	    sound.resumed(function() {
	      Playlist.changeIconInPlaylistToPlay(this.id);
	      window['ga'] && window.ga('send', 'event', 'stream', 'play', this.id);
	    });

	    sound.finished(function() {
	      this.changeIconToPlay(this.id);
	    });
	  });
	},
	addCallbacksToTracks: function(){
    $.each(this.tracks, function(i, sound) {
      var next = Playlist[i+1];

      if (mobileHTML5()) {
        sound.finished(function() {
          next && $(next.ui).trigger('click');
        });
      } else {
        sound.positioned(-10000, function() {
          next && next.load();
        });

        sound.positioned(-180, function() {
          next && $(next.ui).trigger('click');
        });
      }
    });
	},
	changeIconInPlaylistToPlay:function(soundId){
		var controls = $('[data-sound-id='+attr(soundId)+'] .play-button,'+
		                 '[data-sound-id='+attr(soundId)+'] .pause-button');
		controls.removeClass('play-button').addClass('pause-button').
		  find('*').andSelf().filter('.fa-play').removeClass('fa-play').addClass('fa-pause');
	},
	changeIconInPlaylistToPause:function(soundId){
		var controls = $('[data-sound-id='+attr(soundId)+'] .play-button,'+
		                 '[data-sound-id='+attr(soundId)+'] .pause-button');
		controls.removeClass('pause-button').addClass('play-button').
		  find('*').andSelf().filter('.fa-pause').removeClass('fa-pause').addClass('fa-play');
	}
	
};
