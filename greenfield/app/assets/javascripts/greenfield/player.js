//= require greenfield/waveform

$(function() {
  var soundID = function(url) {
    return url.split('/').pop().split('.')[0];
  };

  var waveformData = function(csv) {
    var data = csv.split(',').map(function(s) {
      return parseFloat(s);
    });

    var max = Math.max.apply(Math, data),
        min = Math.min.apply(Math, data);

    var scale = Math.max(Math.abs(max), Math.abs(min));
    data = data.map(function(s) {
      return (s < 0 ? -1 : 1 ) * Math.pow(Math.abs(s) / scale, 1/4);
    });

    return data;
  };

  $(document).on('click', '.play-button', function(e) {
    var container = $(this);
    var url = $(this).find('a').attr('href');
    container.removeClass('play-button fa-play').addClass('pause-button fa-pause');
    soundManager.getSoundById(soundID(url)).play();

    e.preventDefault();
  });

  $(document).on('click', '.pause-button', function(e) {
    var container = $(this);
    var url = $(this).find('a').attr('href');
    container.removeClass('pause-button fa-pause').addClass('play-button fa-play');
    soundManager.pause(soundID(url));

    e.preventDefault();
  });

  $('.waveform').each(function() {
    var container = $(this);
    var data = waveformData($(this).data('waveform'));
    $(this).removeAttr('data-waveform');

    var soundPosition = 0;
    var hoverPosition = -1;
    container.data('waveform', new Waveform({
      container: this,
      innerColor: function(percent, _) {
        if (percent < soundPosition)
          return '#302f2f';
        else
          return '#c7c6c3';
      },
      data: data
    }));

    var scrubber = $(this);
    var player = $(this).parents('.player');
    var seekbar = player.find('.seekbar');
    var index = player.find('.time .index');
    var url = player.find('.play-control a').attr('href');
    var soundID = url.split('/').pop().split('.')[0];

    soundManager.onready(function() {
      var sound = soundManager.createSound({
        id: soundID,
        url: url,
        autoLoad: true,
        whileplaying: function() {
          soundPosition = this.position / this.durationEstimate;
          container.data('waveform').update({ data: data });

          var time = Math.floor(this.position / 1000.0);
          var min = Math.floor(time / 60), sec = time % 60;
          index.text(min + ':' + (sec >= 10 ? sec : '0'+sec));
        },
        onfinish: function() {
          player.find('.play-control').
            removeClass('pause-button').addClass('play-button');
        }
      });

      scrubber.click(function(e) {
        e.preventDefault();

        var offx = e.clientX - scrubber.offset().left;
        sound.setPosition((offx / scrubber.width()) * sound.durationEstimate);
        player.find('.play-button').trigger('click');
      });

      scrubber.mousemove(function(e) {
        var offx = e.clientX - scrubber.offset().left;
        hoverPosition = offx / scrubber.width();
        seekbar.css('left', offx);
      }).mouseout(function() { hoverPosition = -1 });
    });
  });
});

function reconstructWaveform(container) {
  var waveform = container.data('waveform');
  container.find('canvas').remove();
  container.data('waveform', new Waveform({
    container: waveform.container,
    innerColor: waveform.innerColor,
    data: waveform.data
  }));
}
