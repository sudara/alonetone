import HeartController from './heart_controller'

export default class extends HeartController {
  static values = {
    id: Number,
  }

  static outlets = [ "favorite" ]

  isFavorited() {
    return window.userFavorites.includes(this.idValue)
  }

  broadcast() {
    this.favoriteOutlets.forEach((result) => {
      if (this.idValue == result.idValue)
        result.toggle()
    })
  }
}
