import { Controller } from 'stimulus'

export default class extends Controller {
  connect() {
    const containerPaddingLeft = parseInt(window.getComputedStyle(this.element).getPropertyValue('padding-left'), 10)
    const containerPaddingRight = parseInt(window.getComputedStyle(this.element).getPropertyValue('padding-right'), 10)
    this.containerPadding = containerPaddingLeft + containerPaddingRight
    const firstAvatar = document.getElementsByClassName('user_small_avatar')[0]
    this.avatarWidth = parseInt(window.getComputedStyle(firstAvatar).getPropertyValue('width'), 10)
    this.avatarMargin = parseInt(window.getComputedStyle(firstAvatar).getPropertyValue('margin-bottom'), 10)
    this.avatarWidthPlusMargin = this.avatarWidth + this.avatarMargin

    this.resize()
  }

  resize() {
    const containerWidth = this.element.clientWidth - this.containerPadding
    const avatarsPerRow = Math.round(containerWidth / this.avatarWidthPlusMargin)
    const totalMarginWidth = this.avatarMargin * (avatarsPerRow)
    const totalImageWidth = containerWidth - totalMarginWidth
    const newImageWidth = totalImageWidth / avatarsPerRow
    const totalFollowees = this.element.childElementCount

    if (totalFollowees >= avatarsPerRow) {
      const childrenArray = [...this.element.children]
      childrenArray.forEach((avatar) => {
        const thisAvatar = avatar
        thisAvatar.style.width = `${newImageWidth}px`
        thisAvatar.style.height = `${newImageWidth}px`
      })
    }
  }
}
