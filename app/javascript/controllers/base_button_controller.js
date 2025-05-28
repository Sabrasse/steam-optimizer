import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]
  static values = {
    loading: { type: Boolean, default: false }
  }

  connect() {
    // Initialize button state
    this.updateLoadingState()
  }

  loadingValueChanged() {
    this.updateLoadingState()
  }

  updateLoadingState() {
    if (this.loadingValue) {
      this.element.setAttribute("aria-busy", "true")
      this.element.setAttribute("aria-label", "Loading...")
      this.element.disabled = true
    } else {
      this.element.removeAttribute("aria-busy")
      this.element.removeAttribute("aria-label")
      this.element.disabled = false
    }
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