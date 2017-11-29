document.addEventListener("turbolinks:load", function() {
  $(".playlists_carousel").jCarouselLite({
      btnNext: ".next",
      btnPrev: ".prev",
      visible: 4,
      scroll: 4,
      circular: false
  });

  // let us cache forms, make sure that auth tokens are replaced
  $('input[name=authenticity_token]').val($('meta[name=csrf-token]').attr('content'))

  // Tracks
  $('.asset').attach(Track);

  // display listen_count when needed
  if(window.showPlayCounts){
    $('.listen_count').show();
  }

  // Slide open the next element on click
  $('.slide_open_next').attach(SlideOpenNext);

  $('a.confirm_before_delete').click(function(){
    result = confirm('Are you sure?');
    return result;
  });

  // double the text area size when typing a lot
  $('textarea.double_trouble').attach(AdjustableTextarea,16);

  // search submit
  $('#search_button').click(function(){
    $('#search_form').submit();
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
    zindex: 800
  });

  // ability to tab through various track sources
  $('#playlist_tabs').attach(Tabbies);

  // the various groups of tracks you can add to a playlist
  $('#playlist_sources').attach(PlaylistSource);

  // $('#edit_playlist .cover a').attach(SlideOpenNext, '#pic_upload');

  // all links that have the class 'href' will slide open the id that their class id specifies
  $('a.slide_open_href').attach(SlideOpenNext,'href');

  $('a.hide_notice').attach(DismissableNotice);

  // uploader
  $('#uploader').attach(Uploader);

  // single track page love
  $('#single_track .comment_form form').attach(CommentForm);
  $('#single_track a.add_to_favorites').attach(FavoriteToggle);

  // bio
  $('a.follow').attach(FollowToggle);

  // sort playlists
  $('#sort_playlists').sortable({
      revert: true,
      scroll: true,
      cursor: 'move',
      scrollSensitivity: 100,
      update: function(){
        $.post($('#sort_url').attr('href'),
        $.param({'authenticity_token':window.authenticityToken})+'&'+
        $('#sort_playlists').sortable('serialize'));
      }
    });

  // features/blog comment form
  $('#bug_form form').attach(CommentForm);
  $('.comment .comment_form form').attach(CommentForm);
  $('.update .comment_form form').attach(CommentForm);
  $('.feature .comment_form form').attach(CommentForm);

  // mass editing (ajax)
  $('#mass_edit .edit_track form').attach(EditForm);

  $('#radio').attach(Radio);

  jQuery(document).ready(function($) {
    $('a[rel*=facebox]').facebox()
  })

  // stretching divs to stick info to bottom corner of vcard author section
  $('.author_container').each(function() {
    $(this).height($(this).parent().height());
  });

  $('.profile_link').mouseover(function() {
    $('.user_dropdown_menu').animate({top: 0}, 200);
  });

  $('.user_dropdown').mouseleave(function() {
    $('.user_dropdown_menu').animate({top: -118}, 200);
  });

  $('.profile_link').bind('touchstart', function(event) {
    if ( $('.user_dropdown_menu').css('top') == "0px" ) {
    } else {
      event.preventDefault();
      $('.user_dropdown_menu').animate({top: 0}, 200);
    }
  })

});

document.addEventListener("turbolinks:visit", function() {
  TrackInstances().forEach(function(track) {
    track.timer && track.timer.stop();
    soundManager.destroySound(track.soundID);
  });
});
