import { Controller } from 'stimulus'
import { flashController } from './flash_controller'

export default class extends Controller {
  static targets = ['checkbox', 'actualCheckbox', 'markAsPrivate',
    'needsTracksBanner', 'privateBanner']

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
    // The label was clicked, so we still need to check the box
    this.actualCheckboxTarget.checked = !this.actualCheckboxTarget.checked
    this.actualCheckboxTarget.checked ? this.showPrivateBanner() : this.hidePrivateBanner()
  }

}