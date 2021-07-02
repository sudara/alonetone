import { Controller } from 'stimulus'

export default class extends Controller {
  connect() {
    this.totalFollowees = this.element.childElementCount
    const containerPaddingLeft = parseInt(window.getComputedStyle(this.element).getPropertyValue('padding-left'), 10)
    const containerPaddingRight = parseInt(window.getComputedStyle(this.element).getPropertyValue('padding-right'), 10)
    this.containerPadding = containerPaddingLeft + containerPaddingRight
    const firstAvatar = document.getElementsByClassName('user_small_avatar')[0]
    this.avatarWidthFromCSS = parseInt(window.getComputedStyle(firstAvatar).getPropertyValue('width'), 10)
    this.avatarMargin = parseInt(window.getComputedStyle(firstAvatar).getPropertyValue('margin-bottom'), 10)
    this.avatarWidthFromCSSPlusMargin = this.avatarWidthFromCSS + this.avatarMargin

    this.resize()
  }

  resize() {
    const containerWidth = this.element.clientWidth - this.containerPadding
    const avatarsPerRow = Math.round(containerWidth / this.avatarWidthFromCSSPlusMargin)
    const totalMarginWidth = this.avatarMargin * (avatarsPerRow)
    const totalAvailableWidth = containerWidth - totalMarginWidth
    const calculatedAvatarWidth = totalAvailableWidth / avatarsPerRow

    if (this.totalFollowees >= avatarsPerRow) {
      const avatars = this.element.getElementsByClassName('user')
      Array.from(avatars).forEach((avatar) => {
        avatar.style.width = `${calculatedAvatarWidth}px`
        avatar.style.height = `${calculatedAvatarWidth}px`
      })
    }
  }
}
