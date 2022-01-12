import { Controller } from '@hotwired/stimulus'
import { makeSVGFromTitle } from '../animation/default_playlist_images'

export default class extends Controller {
  connect() {
    if (!this.element.hasChildNodes()) {
      this.element.append(makeSVGFromTitle(800, this.element.getAttribute('title')))
    }
  }
}
