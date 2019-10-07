import { Controller } from 'stimulus'

var subNavItemsTotalWidth = 0;
const twoColumnCutoff = 520;

export default class extends Controller {

  connect() {

    this.timer = null
    
    const allItems = this.element.getElementsByTagName("li")
    Array.prototype.forEach.call(allItems, thisListItem => {
      const thisItemMargin = window.getComputedStyle(thisListItem).getPropertyValue('margin-right')
      subNavItemsTotalWidth += thisListItem.offsetWidth + parseInt( thisItemMargin );
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
    
    const headerInner = document.getElementsByClassName("header_inner")[0]
    const sitePadding = 2 * parseInt(window.getComputedStyle(headerInner).getPropertyValue('padding-left'))
    const maxSingleRowAvailableWidth = window.innerWidth - sitePadding;

    if ( maxSingleRowAvailableWidth < twoColumnCutoff ) {
      this.element.classList.add("two-column")
      this.element.classList.remove("three-column")
    } else if ( maxSingleRowAvailableWidth < subNavItemsTotalWidth ) {
      this.element.classList.add("three-column")
      this.element.classList.remove("two-column")
    } else {
      this.element.classList.remove("two-column")
      this.element.classList.remove("three-column")
    }
  }
}