import HeartController from './heart_controller'

export default class extends HeartController {
  isFavorited() {
    this.id = parseInt(this.data.get('asset-id'))
    return window.userFavorites.includes(this.id)
  }
}
