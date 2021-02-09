import HeartController from './heart_controller'

export default class extends HeartController {
  static targets = ['label']

  isFavorited() {
    return this.data.get('following') === 'true'
  }

  faved() {
    this.labelTarget.innerHTML = 'Unfollow'
  }

  unfaved() {
    this.labelTarget.innerHTML = 'Follow'
  }
}
