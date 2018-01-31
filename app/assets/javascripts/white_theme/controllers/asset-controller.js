(function() {
  const application = Stimulus.Application.start()
  application.register("asset", class extends Stimulus.Controller {
  
    initialize() {
     // this.element.addClass('instantiated');
      this.innerPlay = $(".play-button",this.element).children().eq(0);
      this.playButton = $(".play-button",this.element);
      this.trackLink = $("a.track_link",this.element);
      this.time = $('div.counter',this.element);
      this.track_title = $('a.track_link',this.element).html();
      this.artist = $('a.artist',this.element).html();
      this.deleteButton = $(".delete-button",this.element);
      //this.trackURL = $('a.play_link',this.element).attr('href');
      //this.soundID = this.trackURL.split('/').pop().split('.')[0];
      this.seekbar = $('.seekbar', this.element).attach(TrackSeekbar, this);
      this.tabbies = false; // wait on initializing the tabs until we need them
      this.originalDocumentTitle = document.title; // for prepending when playing tracks
      this.radio = false;
      this.reachedEnd = false;
      this.owner = $('.artist',this.element).attr('href').replace('/','');
      // dont allow tab details to be opened on editing playlists
      this.allowDetailsOpen = (this.element.hasClass('unopenable') || (this.element.parent().parent('#single_track').size() > 0)) ? false : true;
    }
    
    toggleDetails(e){

      if (this.details.is(':hidden')) this.openDetails(desiredTab);
      else if (this.isPlaying()) this.openDetails(desiredTab); // never close the tabs when playing
      else this.closeDetails();
      return false;
    }
    
    openDetails(){
      // open the pane if it is not already open
      if(this.isOpen != false) this.more.slideDown(300,function(){
          $('textarea',this).focus();
      });

  		// Show the edit link if admin and/or owner
  		if((this.owner===window.username) || window.userIsAdmin){
  		  $('.show_to_admin_or_owner', this.more).show();

  		  // Show some text prompting them to edit if no description
  		  if($('.description .user_description :not(h3)', this.more).text() == ""){
  		    var href = $('.edit_in_box', this.more).attr('href');
  		    var prompt = '<span class="hint"><a class="hint" href="'+href+'">Add a description</a> to help listeners find your music</span>';
  		     $('.description .user_description', this.more).append(prompt);
  		  }
  		}

  		// Show mp3 details if admin
  		if(window.userIsAdmin){
  		  $('.show_to_admin').show();
  		}

      // close all other detail panes except currently playing
      var instances = TrackInstances();
      for(var i=0; i < instances.length; i++) {
          if(!instances[i].isPlaying() && this.element != instances[i].element)
            instances[i].closeDetails();
      }

      this.element.addClass('open');
    }
  
    closeDetails(e){
      if(!this.allowDetailsOpen || this.commentBoxIsPopulated()) return false;
      this.more.slideUp({duration:300,queue:false});
      this.element.removeClass('open');
    }

  })
  
})()
