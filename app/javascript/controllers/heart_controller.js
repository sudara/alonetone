import { Controller } from 'stimulus'
import FaveAnimation from '../animation/fave_animation'
import Rails from '@rails/ujs'

export default class extends Controller {
  static targets = ['svg']

  initialize() {
    this.favorited = this.isFavorited()
    this.animation = new FaveAnimation(this.element)
    this.animation.init()
    this.animation.setUnfave()
    if (this.favorited) {
      this.animation.setFave()
      this.faved()
    }
  }

  // ajax request fires immediately afterwards
  toggle() {
    if (this.favorited) {
      this.animation.clickUnfave()
      this.favorited = false
      this.unfaved()
      this.unfavorite()
    } else {
      this.animation.clickFave()
      this.favorited = true
      this.faved()
      this.favorite()
    }
  }

  // placeholders for child controllers
  // any html actions
  faved() {}

  unfaved() {}

  // any Rails ajax actions
  favorite() {}

  unfavorite() {}
}
