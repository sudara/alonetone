import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['container']

  connect() {
    this.resize()
  }

  resize() {

    let itemsInRow = Math.round ( this.containerTarget.clientWidth / 58 )

    let containerWidth = this.containerTarget.clientWidth - 24

    let totalMargin = 8 * (itemsInRow)

    let totalImageWidth = containerWidth - totalMargin
    
    let newWidth = totalImageWidth / itemsInRow

    let totalFollowees = this.containerTarget.childElementCount

    if ( totalFollowees >= ( itemsInRow -1 ) ) {
      let children = this.containerTarget.children

      let array = [ ...children ]

      array.forEach(function(item) {
          item.style.width = newWidth + "px"
          item.style.height = newWidth + "px"
      });
    }
  }
}
