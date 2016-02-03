//= require greenfield/sound
//= require greenfield/waveform

function attr(val) {
  return val.replace(/\//g, '\\/');
}

function waveformData(csv) {
  var data = csv.split(',').map(function(s) {
    return parseFloat(s);
  });

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

      var sound, offx;
      if ((sound = Sound.maybeGetSound(soundId))) {
        offx = e.clientX - container.offset().left;
        sound.setPosition(offx / container.width()).play();
      } else {
        player.find('.play-button').trigger('click');
      }
    });

    container.mousemove(function(e) {
      var offx = e.clientX - container.offset().left;
      hoverPosition = offx / container.width();
      seekbar.css('left', offx);
    }).mouseout(function() { hoverPosition = -1 });
  });
}

function changeControlActionToPlay(soundId) {
  var controls = $('[data-sound-id='+attr(soundId)+'] .play-button,'+
                   '[data-sound-id='+attr(soundId)+'] .pause-button');
  controls.removeClass('pause-button').addClass('play-button').
    find('*').andSelf().filter('.fa-pause').removeClass('fa-pause').addClass('fa-play');
}

function changeControlActionToPause(soundId) {
  var controls = $('[data-sound-id='+attr(soundId)+'] .play-button,'+
                   '[data-sound-id='+attr(soundId)+'] .pause-button');
  controls.removeClass('play-button').addClass('pause-button').
    find('*').andSelf().filter('.fa-play').removeClass('fa-play').addClass('fa-pause');
}


$('body').on('click', '[data-sound-id] .play-button', function(e) {
  var soundId = $(this).parent('[data-sound-id]').data('sound-id');
  var li = $('.playlist li[data-sound-id=' + attr(soundId) + ']');
  li.siblings().find('.pause-button').trigger('click');

  var url = $(this).find('*').andSelf().filter('a').attr('href');
  var sound = Sound.load(url.replace(/\.mp3$/, '') + '.mp3');

  sound.rolling = function() {
    $.post(url.replace(/\.mp3$/, '') + '/listens');
  };

  sound.almostFinished = function() {
    var next = $('.playlist li[data-sound-id='+attr(this.id)+']').next().find('.play-button');
    if (next.attr('href'))
      Sound.load(next.attr('href').replace(/\.mp3$/, '') + '.mp3');
  };

  sound.finished = function() {
    changeControlActionToPlay(this.id);
    $('.playlist li[data-sound-id='+attr(this.id)+']').next().find('.play-button').trigger('click');
  };

  sound.paused = function() {
    changeControlActionToPlay(this.id);
    window['ga'] && window.ga('send', 'event', 'stream', 'play', this.id);
  };

  sound.resumed = function() {
    changeControlActionToPause(this.id);
    window['ga'] && window.ga('send', 'event', 'stream', 'play', this.id);
  };

  sound.playing = function() {
    // W3C, IE10+, FF16+, Chrome26+, Opera12+, Safari7+
    var pos = (100*this.position)+'%';
    var li = $('.playlist li[data-sound-id='+attr(this.id)+']');
    li.css('background', 'linear-gradient(to right, #fceabb 0%, #f8b500 '+pos+', #ffffff '+pos+', #ffffff 100%)');

    $('.player[data-sound-id=' + attr(this.id) + '] .waveform').trigger('update.waveform', [this]);
    $('.player[data-sound-id=' + attr(this.id) + '] .time .index').text(this.index);

    changeControlActionToPause(this.id);
  };

  sound.play();

  if (window.location.pathname == $(this).attr('href')) {
    e.preventDefault();
    return false;
  }
});

$('body').on('click', '[data-sound-id] .pause-button', function(e) {
  var soundId = $(this).parent('[data-sound-id]').data('sound-id');

  Sound.pause(soundId);
  changeControlActionToPlay(soundId);

  e.preventDefault();
  return false;
});

$('body').on('ajax:success', '.playlist a[data-remote]', function(e, data) {
  $('.playlist a.small-cover').show();
  $('.track-content').replaceWith($(data).find('.track-content'));
  showWaveform();

  $('.playlist .track').removeClass('active');
  $(e.target).parent('li').find('.track').addClass('active');

  $('.player .play-button').each(function() {
    var url = $(this).find('*').andSelf().filter('a').attr('href');
    Sound.load(url);
  });

  if (window.history.pushState)
    window.history.pushState(null, '', e.target.href);
});

$(document).ready(showWaveform);
