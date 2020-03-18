import { Controller } from 'stimulus'
import { flashController } from './flash_controller'

export default class extends Controller {
  static targets = ['checkbox', 'actualCheckbox', 'markAsPrivate',
    'needsTracksBanner', 'privateBanner', 'fileField', 'fileLabel', 'cover']

  initialize() {
    this.tracksCount = 0
  }

  // called by playlistSort on initialize/add/remove
  updateCount(newCount) {
    this.tracksCount = newCount
    this.displayBanner()
  }

  displayBanner() {
    if (this.tracksCount < 2) {
      this.forcePrivate()
    } else if (this.actualCheckboxTarget.checked) {
      this.showPrivateBanner()
    } else {
      this.checkboxTarget.style.display = 'block'
    }
  }

  forcePrivate() {
    this.actualCheckboxTarget.checked = 1
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
      this.actualCheckboxTarget.value = 0
      this.hidePrivateBanner()
    } else {
      this.actualCheckboxTarget.checked = true
      this.actualCheckboxTarget.value = 1
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