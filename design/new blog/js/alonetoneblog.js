      getTwitters('tweets', { 
      id: 'alonetone', 
      count: 4, 
      enableLinks: true, 
      ignoreReplies: false, 
      clearContents: true,
      template: '<p class="ptweet">%text%<a class="atweet" href="http://twitter.com/%user_screen_name%/statuses/%id%/" class="timelink">%time%</a></p>'
    });
