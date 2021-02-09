import HeartController from './heart_controller'

export default class extends HeartController {
  isFavorited() {
    this.id = parseInt(this.element.href.split('=')[1])
    return window.userFavorites.includes(this.id)
  }
}
