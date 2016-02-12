
Sound = {
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
      loadedActions: [],
      pausedActions: [],
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
          }
        },

        whileplaying: function() {
          var time = Math.floor(this.position / 1000.0);
          var min = Math.floor(time / 60), sec = time % 60;
          sound.position = this.position / this.durationEstimate;
          sound.index    = min + ':' + (sec >= 10 ? sec : '0'+sec);

          for (var i=0; i < sound.playingActions.length; ++i)
            sound.playingActions[i].call(sound);
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
        if (this.sm.playState)
          soundManager.resume(this.sm.id);
        else
          soundManager.play(this.sm.id);
        return this;
      },

      pause: function() {
        soundManager.pause(this.sm.id);
        return this;
      },

      setPosition: function(percent) {
        this.sm.setPosition(percent * this.sm.durationEstimate);
        return this;
      },

      loaded: function(action) {
        if (this.isLoaded)
          action.call(this);
        else
          this.loadedActions.push(action);
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
        this.playingActions.push(action);
      },

      paused: function(action) {
        this.pausedActions.push(action);
      },

      resumed: function(action) {
        this.resumedActions.push(action);
      },

      finished: function(action) {
        this.finishedActions.push(action);
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
  }
};
