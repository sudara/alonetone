import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['checkbox', 'actualCheckbox', 'markAsPrivate',
    'needsTracksBanner', 'privateBanner']

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
    if (!this.hasActualCheckboxTarget) return;
    if (this.actualCheckboxTarget.checked) {
      // redundant, but sometimes this attribute isn't present
      this.actualCheckboxTarget.checked = true
      this.showPrivateBanner()
    } else {
      this.actualCheckboxTarget.checked = false
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
}
