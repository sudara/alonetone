import { Controller } from 'stimulus'

export default class extends Controller {
  
  connect() {
    this.resize()
  }

  resize() {

    let containerWidth = this.element.clientWidth - 24
    let itemsPerRow = Math.round ( this.element.clientWidth / 58 )
    let totalMarginWidth = 8 * (itemsPerRow)
    let totalImageWidth = containerWidth - totalMarginWidth
    let newImageWidth = totalImageWidth / itemsPerRow
    let totalFollowees = this.element.childElementCount

    if ( totalFollowees >= ( itemsPerRow -1 ) ) {

      let children = this.element.children
      let childrenArray = [ ...children ]

      childrenArray.forEach(function(item) {
          item.style.width = newImageWidth + "px"
          item.style.height = newImageWidth + "px"
      });
    }
  }
}
