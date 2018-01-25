Sound = {
  // cache
  store: {},

  getId: function(url) {
    var user, permalink;
    url = url.replace(/^\/+/, '').replace(/\/+$/, '');
    user = url.split('/').shift();
    permalink = url.split('/').pop().split('.')[0];
    return user + '/' + permalink;
  },

  getSound: function(url) {
    var soundId = this.getId(url);
    if (this.store[soundId])
      return this.store[soundId];

    var sound = {
      id: soundId,
      isPlaying: false,
      whilePlayingFired: false,
      loadedActions: [],
      pausedActions: [],
      startedPlayingActions: [],
      playingActions: [],
      resumedActions: [],
      finishedActions: [],

      sm: soundManager.createSound({
        id: soundId,
        url: url,
        autoLoad: false,

        onload: function() {
          if (this.duration) {
            for (var i=0; i < sound.loadedActions.length; ++i)
              sound.loadedActions[i].call(sound);

            sound.loadedActions = [];
            sound.isLoaded = true;
          }
        },

        whileplaying: function() {
          var time = Math.floor(this.position / 1000.0);
          var min = Math.floor(time / 60), sec = time % 60;
          sound.position = this.position / this.durationEstimate;
          sound.index    = min + ':' + (sec >= 10 ? sec : '0'+sec);

          for (var i=0; i < sound.playingActions.length; ++i)
            sound.playingActions[i].call(sound);
          
          // the first time we actually are playing back audio
          // we need to fire a callback to trigger animations to stop
          if(!this.whilePlayingFired){
            this.whilePlayingFired = true
            for (var i=0; i < sound.startedPlayingActions.length; ++i)
              sound.startedPlayingActions[i].call(sound);
          }
        },

        onpause: function() {
          for (var i=0; i < sound.pausedActions.length; ++i)
            sound.pausedActions[i].call(sound);
        },

        onresume: function() {
          for (var i=0; i < sound.resumedActions.length; ++i)
            sound.resumedActions[i].call(sound);
        },

        onplay: function() {
          for (var i=0; i < sound.resumedActions.length; ++i)
            sound.resumedActions[i].call(sound);
        },

        onfinish: function() {
          for (var i=0; i < sound.finishedActions.length; ++i)
            sound.finishedActions[i].call(sound);
        }
      }),

      load: function() {
        this.sm.load();
      },

      play: function() {
        if (this.sm.playState) {
          this.sm.resume();
        } else {
          this.sm.play();
          this.sm.stop();
          this.sm.play();
        }

        this.isPlaying = true;

        return this;
      },

      pause: function() {        
        soundManager.pause(this.sm.id);
        this.isPlaying = false;
        return this;
      },

      setPosition: function(percent) {
        this.sm.setPosition(percent * this.sm.durationEstimate);
        return this;
      },

      loaded: function(action) {
        if (this.isLoaded && action)
          action.call(this);
        else if (action)
          this.loadedActions.push(action);
        else
          this.loadedActions.splice(0);
      },

      positioned: function(pos, action) {
        this.loaded(function() {
          if (pos < 0)
            this.sm.onPosition(this.sm.duration + pos, action);
          else
            this.sm.onPosition(pos, action);
        });
      },
      
      playing: function(action) {
        if (action)
          this.playingActions.push(action);
        else
          this.playingActions.splice(0);
        return this;
      },
      
      startedPlaying:function(action){
        if (action)
          this.startedPlayingActions.push(action);
        else
          this.startedPlayingActions.splice(0);
        return this;
      },

      paused: function(action) {
        if (action)
          this.pausedActions.push(action)
        else
          this.pausedActions.splice(0);

        return this;
      },

      resumed: function(action) {
        if (action)
          this.resumedActions.push(action);
        else
          this.resumedActions.splice(0);

        if (action && this.isPlaying)
          action.call(this);

        return this;
      },

      finished: function(action) {
        if (action)
          this.finishedActions.push(action);
        else
          this.finishedActions.splice(0);
        return this;
      }
    };

    return this.store[soundId] = sound;
  },

  maybeGetSound: function(url) {
    var soundId = this.getId(url);
    return this.store[soundId];
  },

  load: function(url) {
    return this.getSound(url);
  },

  play: function(url) {
    return this.load(url).play();
  },

  pause: function(url) {
    return this.getSound(url).pause();
  },

  pauseAll: function() {    
    for (var soundId in this.store)
      this.store[soundId].pause();
    return this;
  },
  destroyAll: function(){
    for (var soundId in this.store)
      this.store[soundId].destruct();
    return this;
  }
};
