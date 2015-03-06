$(function() {
  var player = $('.player');
  var playerOffset = player.offset().top;
  var placeholder = $('<div>').addClass('player').css({
    'display': 'none',
    'border-top': '1px solid rgba(0, 0, 0, 0)',
    'border-bottom': '1px solid rgba(0, 0, 0, 0)'
  }).insertBefore(player);

  var stuck = false;
  $(window).scroll(function() {
    var wasStuck = stuck;
    stuck = $(this).scrollTop() > playerOffset+25;

    if (!wasStuck && stuck) {
      player.addClass('stuck');
      reconstructWaveform(player.find('.waveform'));
      placeholder.css('display', 'block');
    } else if (wasStuck && !stuck) {
      player.removeClass('stuck');
      reconstructWaveform(player.find('.waveform'));
      placeholder.css('display', 'none');
    }
  });
});

$(document).ready(function(){
  // resizable textarea for edit page
  $('.post_content textarea').autosize();  
});
