import { Controller } from 'stimulus'

let containerPadding = 0
let avatarWidth = 0
let avatarMargin = 0

export default class extends Controller {
  connect() {
    const containerPaddingLeft = parseInt(window.getComputedStyle(this.element).getPropertyValue('padding-left'), 10)
    const containerPaddingRight = parseInt(window.getComputedStyle(this.element).getPropertyValue('padding-right'), 10)
    containerPadding = containerPaddingLeft + containerPaddingRight
    const firstAvatar = document.getElementsByClassName('user_small_avatar')[0]
    avatarWidth = parseInt(window.getComputedStyle(firstAvatar).getPropertyValue('width'), 10)
    avatarMargin = parseInt(window.getComputedStyle(firstAvatar).getPropertyValue('margin-bottom'), 10)

    this.resize()
  }

  resize() {
    const containerWidth = this.element.clientWidth - containerPadding
    const avatarsPerRow = Math.round(this.element.clientWidth / (avatarWidth + avatarMargin))
    const totalMarginWidth = avatarMargin * (avatarsPerRow)
    const totalImageWidth = containerWidth - totalMarginWidth
    const newImageWidth = totalImageWidth / avatarsPerRow
    const totalFollowees = this.element.childElementCount

    if (totalFollowees >= (avatarsPerRow - 1)) {
      const childrenArray = [...this.element.children]

      childrenArray.forEach((avatar) => {
        const thisAvatar = avatar
        thisAvatar.style.width = `${newImageWidth}px`
        thisAvatar.style.height = `${newImageWidth}px`
      })
    }
  }
}
