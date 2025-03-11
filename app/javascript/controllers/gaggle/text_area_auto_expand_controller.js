import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    maxRows: Number
  }

  connect() {
    this.adjustRows()
    this.element.addEventListener('input', this.adjustRows.bind(this))
  }

  disconnect() {
    this.element.removeEventListener('input', this.adjustRows.bind(this))
  }

  adjustRows() {
    const textarea = this.element
    const lines = textarea.value.split('\n').length

    if (this.maxRowsValue) {
      textarea.rows = Math.max(1, Math.min(this.maxRowsValue, lines))
    } else {
      textarea.rows = lines
    }
  }
}