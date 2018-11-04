import HeartController from './heart_controller'

export default class extends HeartController {
  isFavorited() {
    return this.data.get('following') === 'true'
  }
}
