import HeartController from './heart_controller'

export default class extends HeartController {
  static values = {
    id: Number,
  }

  get userFavorites() {
    return this.application.getControllerForElementAndIdentifier(document.body, 'user-favorites')
  }

  isFavorited() {
    return this.userFavorites?.has(this.idValue) ?? false
  }

  faved() {
    this.userFavorites?.add(this.idValue)
  }

  unfaved() {
    this.userFavorites?.remove(this.idValue)
  }
}
