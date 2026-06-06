/* eslint no-console:0 */
import LocalTime from 'local-time'
import { Turbo } from '@hotwired/turbo-rails'
import gsap from 'gsap'
import './misc/bugsnag'
import './controllers'

LocalTime.config.i18n.en.datetime.at = '{date}' // drop the time from the date
LocalTime.config.i18n.en.date.on = '{date}' // no "on Sunday", just "Sunday"
LocalTime.start()

function handlers() {
  document.querySelectorAll('.slide_open_href').forEach((link) => {
    link.addEventListener('click', (event) => {
      const id = event.target.getAttribute('href')
      document.querySelector(id).style.display = 'block'
      event.preventDefault()
    })
  })
}
document.addEventListener('turbo:load', handlers)

// Re-exported so esbuild's --global-name=Alonetone exposes Alonetone.gsap
export { gsap, Turbo }
