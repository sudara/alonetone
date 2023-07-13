import HeartController from './heart_controller'

export default class extends HeartController {
  static values = {
    id: Number,
  }

  connect() {
    // access controller from child element
    this.element[this.identifier] = this
  }

  isFavorited() {
    return window.userFavorites.includes(this.idValue)
  }

  toggle({broadcast=true}) {
    super.toggle()

    if (broadcast)
      this.broadcast()
  }

  broadcast() {
    const matches = document.querySelectorAll(`[data-favorite-id-value="${this.idValue}"]`)
    matches.forEach((element) => {
      if (element === this.element)
        return

      element.favorite.toggle({broadcast: false})
    })
  }
}
