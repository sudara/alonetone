import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    ids: Array,
  }

  has(id) {
    return this.idsValue.includes(id)
  }

  add(id) {
    if (!this.has(id)) this.idsValue = [...this.idsValue, id]
  }

  remove(id) {
    this.idsValue = this.idsValue.filter((existing) => existing !== id)
  }
}
