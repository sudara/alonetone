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
