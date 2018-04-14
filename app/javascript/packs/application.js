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

import { Application } from 'stimulus'
import { definitionsFromContext } from 'stimulus/webpack-helpers'
import { makeSVGFromTitle } from '../animation/default_playlist_images'

const Turbolinks = require('turbolinks')

Turbolinks.start()

LocalTime.start()

const application = Application.start()
const context = require.context('../controllers', true, /\.js$/)
application.load(definitionsFromContext(context))

document.addEventListener('turbolinks:load', function() {
  document.querySelectorAll('#playlist-and-track-content .no_pic').forEach((pic) => {
    const title = document.querySelector('h1:first').text().trim()
    pic.append(makeSVGFromTitle(800, title))
    pic.removeClass('.no_pic') // otherwise turbolinks:visit will keep appending
  })

  document.querySelectorAll('li a .no_pic').forEach((pic) => {
    const title = pic.parentNode.getAttribute('title')
    pic.append(makeSVGFromTitle(800, title))
    pic.classList.remove('.no_pic') // otherwise turbolinks:visit will keep appending
  })

  // $(this).parent().attr('title').trim()
  // 'li a .no_pic'
})
