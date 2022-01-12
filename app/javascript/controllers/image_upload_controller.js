import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['fileField', 'fileLabel', 'image']

  openFile(e) {
    this.fileLabelTarget.click()
  }

  fileChanged(e) {
    this.displayPreview(e.target)
  }

  removePic(e) {
    e.preventDefault()
    this.imageTarget.innerHTML = '<div class="generated_svg_cover" data-controller="svg-cover"></div>'
    this.fileFieldTarget.value = ''
  }

  displayPreview(input) {
    const reader = new FileReader()
    if (input.files && input.files[0]) {
      reader.onload = (e) => {
        const image = document.createElement('img')
        image.src = e.target.result
        this.imageTarget.innerHTML = ''
        this.imageTarget.appendChild(image)
      }
      reader.readAsDataURL(input.files[0]);
    }
  }
}
