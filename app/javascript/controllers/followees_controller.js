import { Controller } from 'stimulus'

export default class extends Controller {
  
  connect() {
    this.resize()
  }

  resize() {

    let itemsInRow = Math.round ( this.element.clientWidth / 58 )

    let containerWidth = this.element.clientWidth - 24

    let totalMargin = 8 * (itemsInRow)

    let totalImageWidth = containerWidth - totalMargin
    
    let newWidth = totalImageWidth / itemsInRow

    let totalFollowees = this.element.childElementCount

    if ( totalFollowees >= ( itemsInRow -1 ) ) {
      let children = this.element.children

      let array = [ ...children ]

      array.forEach(function(item) {
          item.style.width = newWidth + "px"
          item.style.height = newWidth + "px"
      });
    }
  }
}
