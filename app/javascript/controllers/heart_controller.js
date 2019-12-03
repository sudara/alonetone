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
      this.unfavore()
    } else {
      this.animation.clickFave()
      this.favorited = true
      this.faved()
      this.favore()
    }
  }
  unfavore() {
    Rails.ajax({
      url: `/favorites/delete`,
      type: 'PUT',
      data: `asset_id=${this.data.get('asset-id')}`
    })
  }

  favore() {
    Rails.ajax({
      url: `/favorites`,
      type: 'POST',
      data: `asset_id=${this.data.get('asset-id')}`
    })
  }

  // placeholders for child controllers
  faved() {}

  unfaved() {}
}
