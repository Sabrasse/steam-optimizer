import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "spinner", "submitButton", "results", "input", "errorMessage" ]

  submit(event) {
    // Clear any existing error messages
    this.clearError()
    
    // Validate input before submission
    const inputValue = this.inputTarget.value.trim()
    if (!inputValue) {
      event.preventDefault()
      this.showError("Please enter a Steam App ID or URL.")
      return false
    }

    // Show the spinner text and disable the submit button on form submission
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.style.display = "inline"
    }
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = true
    }
    
    // Scroll to results if they exist
    if (this.hasResultsTarget) {
      setTimeout(() => {
        this.resultsTarget.scrollIntoView({ behavior: 'smooth' })
      }, 500)
    }
  }

  showError(message) {
    if (this.hasErrorMessageTarget) {
      this.errorMessageTarget.textContent = message
      this.errorMessageTarget.style.display = "block"
      this.inputTarget.classList.add("is-invalid")
    }
  }

  clearError() {
    if (this.hasErrorMessageTarget) {
      this.errorMessageTarget.style.display = "none"
      this.inputTarget.classList.remove("is-invalid")
    }
  }

  // Clear error when user starts typing
  inputChanged() {
    if (this.inputTarget.value.trim()) {
      this.clearError()
    }
  }
} 