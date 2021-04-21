import HeartController from './heart_controller'

export default class extends HeartController {
  static targets = ['label']

  static values = {
    following: Boolean,
  }

  isFavorited() {
    return this.followingValue;
  }

  faved() {
    this.labelTarget.innerHTML = 'Unfollow'
  }

  unfaved() {
    this.labelTarget.innerHTML = 'Follow'
  }
}
