import { Application } from "@hotwired/stimulus"

const gaggleApplication = Application.start()

// Configure Stimulus development experience
gaggleApplication.debug = false
window.Stimulus   = gaggleApplication

export { gaggleApplication }