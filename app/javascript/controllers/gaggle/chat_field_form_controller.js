import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submitForm() {
    this.element.closest('form').requestSubmit()
  }
}