import Sortable from 'sortablejs'
import { Controller } from "@hotwired/stimulus"
import { flashController } from './flash_controller'
import csrfFetch from '../misc/csrf_fetch'

export default class extends Controller {
  static targets = ['sortable', 'feedback']

  initialize() {
    if (this.data.get('enabled') === 'true') {
      this.setupSortable()
    }
  }

  //  "playlist"=>["10", "7", "146", "8", "88", "3895", "160", "8969", "9110", "10434", "14789", "15274", "18687"], "user_id"=>"sudara"}
  paramsFromSortables() {
    return `playlist[]=${this.sortable.toArray().join('&playlist[]=')}`
  }

  // only fire when order changed
  maybePostToSort() {
    const newParams = this.paramsFromSortables()
    if (newParams !== this.currentParams) {
      this.currentParams = newParams
      this.sort()
    }
  }

  setupSortable() {
    this.sortable = new Sortable(this.sortableTarget, {
      onEnd: () => this.maybePostToSort(),
    })
    this.currentParams = this.paramsFromSortables()
  }

  sort() {
    csrfFetch(`${window.location}/sort`, {
      method: 'POST',
      body: new URLSearchParams(this.currentParams),
    })
      .then((r) => {
        if (!r.ok) throw new Error('sort failed')
        this.displaySuccess()
      })
      .catch(() => flashController.alertFailed())
  }

  displaySuccess() {
    flashController.alertSaved()
  }
}
