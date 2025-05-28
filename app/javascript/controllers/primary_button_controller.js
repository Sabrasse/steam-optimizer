import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]
  static values = {
    loading: { type: Boolean, default: false }
  }

  connect() {
    // Initialize the button
  }

  // Handle click events
  click(event) {
    if (this.loadingValue) {
      event.preventDefault()
      return
    }
  }

  // Set loading state
  setLoading() {
    this.loadingValue = true
  }

  // Reset loading state
  resetLoading() {
    this.loadingValue = false
  }
} 