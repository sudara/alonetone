import HeartController from './heart_controller'
import Rails from '@rails/ujs'

export default class extends HeartController {
  isFavorited() {
    this.id = parseInt(this.data.get('asset-id'))
    return window.userFavorites.includes(this.id)
  }

  unfavorite() {
    Rails.ajax({
      url: `/favorites/delete`,
      type: 'PUT',
      data: `asset_id=${this.data.get('asset-id')}`
    })
  }

  favorite() {
    Rails.ajax({
      url: `/favorites`,
      type: 'POST',
      data: `asset_id=${this.data.get('asset-id')}`
    })
  }
}
