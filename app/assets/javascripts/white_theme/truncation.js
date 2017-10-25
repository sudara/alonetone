(function($) {

    var playButtonAndTimeWidth = 90; // make this dynamic?

    $( window ).resize(function() {
      $("a.track_link").width( $(".box").width() - playButtonAndTimeWidth );
    });

    document.addEventListener("turbolinks:load", function() {
        $("a.track_link").width( $(".box").width() - playButtonAndTimeWidth );
    });

})(jQuery);