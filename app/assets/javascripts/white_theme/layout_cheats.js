(function($) {

    document.addEventListener("turbolinks:load", function() {


        if ( $(".latest-playlists-header").length > 0 ) {
        


            $("h2.box").each( function() {
                $(this).prependTo( $(this).next() );
                $(this).removeClass("box");
            });

            $(".footer_box .view_all").each( function() {
                $(this).prependTo( $(this).parent().prev() );
            });

            $(".footer_box").remove();

        } else {

            $("h2.box").each( function() {
                // $(this).prependTo( $(this).next() );
                $(this).removeClass("box");
            });

            $(".footer_box .view_all").each( function() {
                $(this).prependTo( $(this).parent().prev() );
            });

            $(".footer_box").remove();
            
        }



    });

})(jQuery);