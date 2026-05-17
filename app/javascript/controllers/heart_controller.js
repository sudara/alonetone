import { Controller } from "@hotwired/stimulus"
import FaveAnimation from '../animation/fave_animation'

export default class extends Controller {
  static targets = ['svg']

  static values = {
    favorited: Boolean,
  }

  initialize() {
    this.animation = new FaveAnimation(this.element)
    this.animation.init()
  }

  // Runs after outlets/values are wired, so subclasses can use them in isFavorited().
  connect() {
    this.favorited = this.isFavorited()
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

  isFavorited() {
    return this.favoritedValue
  }

  // placeholders for child controllers
  faved() {}

  unfaved() {}
}
