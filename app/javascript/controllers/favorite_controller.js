import HeartController from './heart_controller'

export default class extends HeartController {
  static values = {
    id: Number,
  }

  isFavorited() {
    return window.userFavorites.includes(this.idValue)
  }
}
