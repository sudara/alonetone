import Rails from 'rails-ujs'
import { Controller } from 'stimulus'
import { Chart } from '../../../../node_modules/frappe-charts/dist/frappe-charts.esm.js'

export default class extends Controller {
  static targets = ['daily']

  initialize() {
    this.chart = new Chart(this.dailyTarget, {
      data: {
        datasets: [],
        labels: [],
      },
      type: 'bar',
      height: 125,
      width: 250,
      valuesOverPoints: 1,
      barOptions: {
        spaceRatio: 0.2,
      },
      showLegend: 0,
      showToolTip: 0,
      colors: ['#7cd6fd', '#743ee2', '#000']
    })
    this.grabData('daily', this.dailyTarget)
  }

  grabData(type, target) {
    const chart = this.chart
    Rails.ajax({
      url: '/admin/users/stats.json',
      type: 'GET',
      data: '',
      success(data) {
        console.log(data)
        chart.update(data)
      },
    })
  }

}