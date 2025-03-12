import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display"]
  static values = { utc: String }

  connect() {
    this.updateTime()
  }

  updateTime() {
    const date = new Date(this.utcValue)
    const options = {
      hour: 'numeric',
      minute: '2-digit',
      hour12: true
    }
    const formattedTime = date.toLocaleTimeString([], options)
    this.displayTarget.textContent = formattedTime
  }
}