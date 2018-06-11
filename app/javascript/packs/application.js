/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

// src/application.js

import LocalTime from 'local-time'
import Rails from 'rails-ujs';
import { Application } from 'stimulus'
import { definitionsFromContext } from 'stimulus/webpack-helpers'
import { makeSVGFromTitle } from '../animation/default_playlist_images'

const Turbolinks = require('turbolinks')

Rails.start()
Turbolinks.start()
LocalTime.start()

const application = Application.start()
const context = require.context('../controllers', true, /\.js$/)
application.load(definitionsFromContext(context))


function handlers() {
  document.querySelectorAll('.large-cover .no_pic, .small-cover .no_pic').forEach((pic) => {
    const title = document.querySelector('h1').textContent.trim()
    if (!pic.hasChildNodes()) { 
      pic.append(makeSVGFromTitle(800, title))
    }
  })

  document.querySelectorAll('li a .no_pic').forEach((pic) => {
    const title = pic.parentNode.getAttribute('title')  
    if (!pic.hasChildNodes()) {
      pic.append(makeSVGFromTitle(800, title))
    }
  })

  document.querySelectorAll('.tracklist .play-button').forEach((playlistTrack) => {
    playlistTrack.addEventListener('click',function(e) {
      document.addEventListener('turbolinks:load', function(event) {
        const click = document.createEvent('Event');
        click.initEvent('click', true, true); //can bubble, and is cancellable
        document.querySelector('.play-button-container').dispatchEvent(click)
      })
      console.log(document.querySelector('.play-button-container'))
      Turbolinks.visit(e.currentTarget.getAttribute('href'))
    })
  })
}

document.addEventListener('turbolinks:load', handlers)
