import { Controller } from 'stimulus'

var navItemsTotalWidth = 0;

export default class extends Controller {

  initialize() {
    
    this.timer = null

    const allItems = this.element.getElementsByTagName("li")
    Array.prototype.forEach.call(allItems, a => {
      
      const thisMargin = window.getComputedStyle(a).getPropertyValue('margin-right')

      navItemsTotalWidth += a.offsetWidth + parseInt( thisMargin );
    });

    this.actuallyResize()
  }

  // debounce the window.onresize events
  resize() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => {
      this.actuallyResize()
    }, 50)
  }

  actuallyResize() {

    const maxWidthElement = document.getElementsByClassName("header_inner")[0]

    const maxWidth = parseInt(  window.getComputedStyle(maxWidthElement).getPropertyValue('width'))  - parseInt(window.getComputedStyle(maxWidthElement).getPropertyValue('padding-right') ) - parseInt (window.getComputedStyle(maxWidthElement).getPropertyValue('padding-left') )

    console.log ( maxWidth )
    
    if ( navItemsTotalWidth > maxWidth ) {
      this.element.classList.add("three-column")
    } else {
      this.element.classList.remove("three-column")
    }
    if ( 520 > maxWidth ) {
      this.element.classList.add("two-column")
      this.element.classList.remove("three-column")
    } else {
      this.element.classList.remove("two-column")
    }
  }
}