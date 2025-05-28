import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    loading: Boolean
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
    } else {
      this.element.removeAttribute("aria-busy")
      this.element.removeAttribute("aria-label")
    }
  }
} 