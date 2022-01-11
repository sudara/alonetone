import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['credits', 'sidebar', 'content', 'cover', 'sidebarDownloads', 'smallCover']

  initialize() {
    this.resize()
  }

  hideCover() {
    this.sidebarDownloadsTarget.style.display = 'block'
    this.smallCoverTarget.style.display = 'block'
    document.body.classList.remove('cover_view')
    this.resize()
  }

  showCover() {
    this.sidebarDownloadsTarget.style.display = 'none'
    this.smallCoverTarget.style.display = 'none'
    history.pushState(this.smallCoverTarget.textContent, '', this.smallCoverTarget.href)
    document.body.classList.add('cover_view')
    this.resize();
  }

  resize() {
    if (this.hasCoverTarget) {
      if (this.hasCreditsTarget) {
        this.alignCredits()
      }
      this.roundBottomRightCorner()
    }
  }

  alignCredits() {
    if (this.isTwoColumn()) {
      this.creditsTarget.style.width = `${this.contentTarget.clientWidth}px`
      this.element.style.paddingBottom = `${this.offset()}px`
    } else {
      this.creditsTarget.style.width = '100%'
      this.element.style.paddingBottom = '0px'
    }
  }

  roundBottomRightCorner() {
    if (this.heightDifference() > 0) {
      this.sidebarTarget.classList.add('rounded_bottom_right_corner')
    } else {
      this.sidebarTarget.classList.remove('rounded_bottom_right_corner')
    }
  }

  isTwoColumn() {
    return window.getComputedStyle(this.creditsTarget).getPropertyValue('position') === 'absolute'
  }

  heightDifference() {
    return this.sidebarTarget.clientHeight - this.contentTarget.clientHeight
  }

  offset() {
    const mainElement = document.getElementsByTagName('main')[0]
    const mainPaddingBottom = parseInt(window.getComputedStyle(mainElement).getPropertyValue('padding-bottom'), 10 )
    return this.creditsTarget.clientHeight - this.heightDifference() - mainPaddingBottom
  }

}
