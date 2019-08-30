import { Controller } from 'stimulus'
import FaveAnimation from '../animation/fave_animation'

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
    } else {
      this.animation.clickFave()
      this.favorited = true
      this.faved()
    }
  }

  // placeholders for child controllers
  faved() {}

  unfaved() {}
}
