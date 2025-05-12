import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "spinner", "submitButton", "results" ]

  submit(event) {
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
} 