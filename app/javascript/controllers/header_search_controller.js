import { Controller } from 'stimulus'

export default class extends Controller {
  
  submitForm() {
    const searchForm = document.getElementById('search_form')
    searchForm.submit();
  }

}
