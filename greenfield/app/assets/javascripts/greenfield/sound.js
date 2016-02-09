
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
      loadActions: [],
      sm: soundManager.createSound({
        id: soundId,
        url: url,
        autoLoad: false,

        onload: function() {
          if (this.duration) {
            for (var i=0; i < sound.loadActions.length; ++i)
              sound.loadActions[i].call(sound);

            sound.loadActions = [];
          }
        },

        whileplaying: function() {
          var time = Math.floor(this.position / 1000.0);
          var min = Math.floor(time / 60), sec = time % 60;
          sound.position = this.position / this.durationEstimate;
          sound.index    = min + ':' + (sec >= 10 ? sec : '0'+sec);

          sound.playingAction && sound.playingAction();
        },

        onpause: function() {
          sound.pausedAction && sound.pausedAction();
        },

        onresume: function() {
          sound.resumedAction && sound.resumedAction();
        },

        onplay: function() {
          sound.resumedAction && sound.resumedAction();
        },

        onfinish: function() {
          sound.finishedAction && sound.finishedAction();
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
          this.loadActions.push(action);
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
        this.playingAction = action;
      },

      paused: function(action) {
        this.pausedAction = action;
      },

      resumed: function(action) {
        this.resumedAction = action;
      },

      finished: function(action) {
        this.finishedAction = action;
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
