/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// src/application.js

import LocalTime from 'local-time'
import { Turbo } from '@hotwired/turbo-rails'
import { Application } from '@hotwired/stimulus'
import Bugsnag from '@bugsnag/js'
import { definitionsFromContext } from '@hotwired/stimulus-webpack-helpers'
import gsap from 'gsap' // needed for tests to run
import Playlist from '@alonetone/stitches'
import './misc/bugsnag.js.erb'

// uncomment for local stitches dev:
// import Playlist from '../../../../stitches/src/playlist'

LocalTime.config.i18n.en.datetime.at = '{date}' // drop the time from the date
LocalTime.config.i18n.en.date.on = '{date}' // no "on Sunday", just "Sunday"
LocalTime.start()

window.Stimulus = Application.start()
const context = require.context('./controllers', true, /\.js$/)
Stimulus.load(definitionsFromContext(context))

const playlist = new Playlist()

function handlers() {
  /*
    We want to "promote" turbo frame loads to full turbo:loads
    But this would break continuous playback
    because stitches would be reloaded on every frame load.

    There's a whole other can of worms: it would be trivial
    to *allow* playback to continue across turbo visits
    and therefore to allow people to listen to tunes while they browse all of alonetone.
    However, this means we'd need a global player (like back in the old days!).

    So for now, (re)-load stitches on every pageload *unless* we are on a playlist page.
    And we load stitches via playlist_controller controller on initialize.
    Perhaps ideally each group of tracks on alonetone would be its own stitches playlist too...
  */

  if (document.getElementById('playlist_and_track_content') == null) {
    playlist.setup({
      preloadIndex: -1,
      tracksSelector: '.stitches_track',
      timeSelector: '.stitches_time',
      playButtonSelector: '.stitches_play',
      loadingProgressSelector: '.stitches_seek .loaded',
      playProgressSelector: '.stitches_seek .played',
      seekSelector: '.stitches_seek',
      enableConsoleLogging: false,
      whilePlaying: () => {
      },
      onError: (data) => {
        Bugsnag.notify(`MP3 Playback Error: ${data.code} ${data.message} ${data.filename}`)
      },
    })
  } else {
    // transitioning to a playlist player, we'll need to pause
    playlist && playlist.reset()
  }

  document.querySelectorAll('.slide_open_href').forEach((link) => {
    link.addEventListener('click', (event) => {
      const id = event.target.getAttribute('href')
      document.querySelector(id).style.display = 'block'
      event.preventDefault()
    })
  })
}
document.addEventListener('turbo:load', handlers)

// document.addEventListener('turbo:submit-start', () => {
//   Turbo.setProgressBarDelay(10)
//   Turbo.navigator.delegate.adapter.showProgressBar();
// })

// document.addEventListener('turbo:submit-end', (e) => {
//   Turbo.setProgressBarDelay(300)
//   Turbo.navigator.delegate.adapter.progressBar.hide();
//   if (e.detail.success === false) {
//     e.target.previousElementSibling.scrollIntoView(true) // scroll to top of form
//   }
// })
// Expose on the console as Alonetone.gsap, etc
export {
  gsap,
  playlist,
}
