
Sound = {
  store: {},

  getSound: function(url) {
    var soundId = url.split('/').pop().split('.')[0];
    if (this.store[soundId])
      return this.store[soundId];

    var sound = {
      sm: soundManager.createSound({
        id: soundId,
        url: url,
        autoLoad: true,

        onload: function() {
          if (this.duration) {
            this.onPosition(this.duration - 10000, function() {
              sound.almostFinished && sound.almostFinished();
            });

            this.onPosition(5000, function() {
              sound.rolling && sound.rolling();
            });
          }
        },

        whileplaying: function() {
          var time = Math.floor(this.position / 1000.0);
          var min = Math.floor(time / 60), sec = time % 60;
          sound.position = this.position / this.durationEstimate;
          sound.index    = min + ':' + (sec >= 10 ? sec : '0'+sec);

          sound.playing && sound.playing();
        },

        onpause: function() {
          sound.paused && sound.paused();
        },

        onresume: function() {
          sound.resumed && sound.resumed();
        },

        onplay: function() {
          sound.resumed && sound.resumed();
        },

        onfinish: function() {
          sound.finished && sound.finished();
        }
      }),

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
      }
    };

    return this.store[soundId] = sound;
  },

  maybeGetSound: function(url) {
    var soundId = url.split('/').pop().split('.')[0];
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
