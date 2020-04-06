import { Controller } from 'stimulus'
import { flashController } from './flash_controller'

export default class extends Controller {
  static targets = ['checkbox', 'actualCheckbox', 'markAsPrivate',
    'needsTracksBanner', 'privateBanner', 'fileField', 'fileLabel', 'cover']

  initialize() {
    this.tracksCount = 0
    this.updateBanner()
  }

  // called by playlistSort on initialize/add/remove
  updateCount(newCount) {
    this.tracksCount = newCount
    if (this.tracksCount < 2) {
      this.forcePrivate()
    } else {
      this.updateBanner()
    }
  }

  updateBanner() {
    if (this.actualCheckboxTarget.checked) {
      this.actualCheckboxTarget.checked = true // redundant, but sometimes this attribute isn't present
      this.showPrivateBanner()
    } else {
      this.actualCheckboxTarget.checked = false // redundant, but sometimes this attribute isn't present
      this.checkboxTarget.style.display = 'block'
      this.hidePrivateBanner()
    }
  }

  forcePrivate() {
    this.actualCheckboxTarget.checked = true
    this.showNeedsTracksBanner()
    this.checkboxTarget.style.display = 'none'
  }

  showNeedsTracksBanner() {
    this.needsTracksBannerTarget.style.display = 'block'
    this.privateBannerTarget.style.display = 'none'
  }

  showPrivateBanner() {
    this.needsTracksBannerTarget.style.display = 'none'
    this.privateBannerTarget.style.display = 'block'
    this.checkboxTarget.style.display = 'block'
  }

  hidePrivateBanner() {
    this.privateBannerTarget.style.display = 'none'
  }

  togglePrivate(e) {
    e.preventDefault()
    if (this.actualCheckboxTarget.checked) {
      this.actualCheckboxTarget.checked = false
      this.hidePrivateBanner()
    } else {
      this.actualCheckboxTarget.checked = true
      this.showPrivateBanner()
    }
  }

  openFile(e) {
    this.fileLabelTarget.click()
  }

  fileChanged(e) {
    this.displayPreview(e.target)
  }


  removePic(e) {
    e.preventDefault()
    this.coverTarget.innerHTML = '<div class="no_pic"></div>'
    this.fileFieldTarget.value = ''

  }

  displayPreview(input) {
    const reader = new FileReader()
    if (input.files && input.files[0]) {
      reader.onload = (e) => {
        const image = document.createElement('img')
        image.src = e.target.result
        this.coverTarget.innerHTML = ''
        this.coverTarget.appendChild(image)
      }
      reader.readAsDataURL(input.files[0]);
    }
  }

}