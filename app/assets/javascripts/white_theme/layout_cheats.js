(function($) {

    document.addEventListener("turbolinks:load", function() {

        $("h2.box").each( function() {
            $(this).prependTo( $(this).next() );
            $(this).removeClass("box");
        });

        $(".footer_box .view_all").each( function() {
            $(this).prependTo( $(this).parent().prev() );
        });

        $(".footer_box").remove();

    });

})(jQuery);