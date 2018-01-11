// Not Currently in Use!


(function($) {

    document.addEventListener("turbolinks:load", function() {
        
        // For the /playlists page, align oprhan rows to the left using this 0 height div trick
        for (var i = 0; i < 8; i++) {
            var $flexInvisibleDiv = $("<li></li>").appendTo( $("main > ul.playlists") );
            // $flexInvisibleDiv.width( $flexInvisibleDiv.prev().width() );
        }


        // If the playlists on the user page extend to more than one line,
        // use this technique for aligning the orphan row
        if ( $("#user_playlists_area ul.playlists").height() > 300 ) {
	        for (var i = 0; i < 8; i++) {
				var $flexInvisibleDiv = $("<li></li>").appendTo( $("#user_playlists_area ul.playlists") );
				// $flexInvisibleDiv.width( $flexInvisibleDiv.prev().width() );
	        }
        }
        
        // If the playlists on the user page are 3 or less,
        // skip the usual flex-box formatting with this added class
        if ( ( $("#user_playlists_area ul.playlists").length > 0 ) && ( $("#user_playlists_area ul.playlists li").length < 4 ) ) {
            // $("#user_playlists_area ul.playlists").addClass("three_or_less_playlists");
        }

    });

})(jQuery);