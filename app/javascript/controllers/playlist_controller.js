import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['credits', 'sidebar', 'content']

  initialize() {
    this.resize()
  }

  resize() {
    if (this.isCoverView()) {
      if (this.hasCredits()) {
        this.alignCredits()
      }
      this.roundBottomRightCorner()
    }
  }

  alignCredits() {
    if (this.isTwoColumn()) {
      this.creditsTarget.style.width = this.contentTarget.clientWidth + "px"
      this.element.style.paddingBottom = this.offset() + "px"
    } else {
      this.creditsTarget.style.width = "100%"
      this.element.style.paddingBottom = "0px"
    }
  }

  roundBottomRightCorner() {
    if ( this.heightDifference() > 0 ) {
      this.sidebarTarget.classList.add('rounded_bottom_right_corner')
     } else {
        this.sidebarTarget.classList.remove('rounded_bottom_right_corner')
    }
  }
  
  hasCredits() {
    return this.hasCreditsTarget
  }

  isCoverView() {
    return document.body.classList.contains('cover_view')
  }

  isTwoColumn() {
    return window.getComputedStyle(this.creditsTarget).getPropertyValue('position') == 'absolute'
  }

  heightDifference() {
    return this.sidebarTarget.clientHeight - this.contentTarget.clientHeight
  }

  offset() {
    const mainElement = document.getElementsByTagName("main")[0]
    const mainPaddingBottom = parseInt( window.getComputedStyle(mainElement).getPropertyValue('padding-bottom'), 10 )
    return this.creditsTarget.clientHeight - this.heightDifference() - mainPaddingBottom
  }

}
