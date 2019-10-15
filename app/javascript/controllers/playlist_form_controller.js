import { Controller } from 'stimulus'
import { flashController } from './flash_controller'

export default class extends Controller {
  static targets = ['privateCheckbox', 'actualCheckbox', 'markAsPrivate',
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
    if(this.tracksCount < 2) {
      this.actualCheckboxTarget.checked = 1
      this.showNeedsTracksBanner()
      this.privateCheckbox.style.display = 'none'

    } elseif(this.actualCheckboxTarget.checked) {
      this.showPrivateBanner()
      this.privateCheckbox.style.display = 'block'
    } else {
      this.privateCheckbox.style.display = 'block'
    }
  }

  showNeedsTracksBanner() {
    this.needsTracksBannerTarget.style.display = 'block'
    this.privateBannerTarget.style.display = 'none'
  }

  showPrivateBanner() {
    this.needsTracksBannerTarget.style.display = 'none'
    this.privateBannerTarget.style.display = 'block'
  }

  togglePrivate() {
    // The label was clicked, so we still need to check the box
    this.actualCheckboxTarget.checked = !this.actualCheckboxTarget.checked
  }

}