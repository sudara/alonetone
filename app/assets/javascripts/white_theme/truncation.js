(function($) {

    var playButtonAndTimeWidth = 90; // make this dynamic?

    $( window ).resize(function() {
      $("a.track_link").width( $(".asset").width() - playButtonAndTimeWidth );
    });

    document.addEventListener("turbolinks:load", function() {
        $("a.track_link").width( $(".asset").width() - playButtonAndTimeWidth );
    });

})(jQuery);