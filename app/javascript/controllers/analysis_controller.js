import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["section", "step", "prevButton", "nextButton"]
  // This is a test
  connect() {
    this.currentSectionIndex = 0
    this.updateNavigation()
    
    // Initialize tooltips
    const tooltips = document.querySelectorAll('[data-bs-toggle="tooltip"]')
    tooltips.forEach(tooltip => new bootstrap.Tooltip(tooltip))
    
    // Setup polling if needed
    if (this.element.dataset.processing === "true") {
      this.startPolling()
    }
  }
  
  updateNavigation() {
    this.prevButtonTarget.disabled = this.currentSectionIndex === 0
    this.nextButtonTarget.disabled = this.currentSectionIndex === this.sectionTargets.length - 1
    
    // Update steps
    this.stepTargets.forEach((step, index) => {
      if (index <= this.currentSectionIndex) {
        step.classList.add('active')
      } else {
        step.classList.remove('active')
      }
    })
    
    // Update sections
    this.sectionTargets.forEach((section, index) => {
      if (index === this.currentSectionIndex) {
        section.classList.add('active')
      } else {
        section.classList.remove('active')
      }
    })
  }
  
  previous() {
    if (this.currentSectionIndex > 0) {
      this.currentSectionIndex--
      this.updateNavigation()
    }
  }
  
  next() {
    if (this.currentSectionIndex < this.sectionTargets.length - 1) {
      this.currentSectionIndex++
      this.updateNavigation()
    }
  }
  
  copyShareLink() {
    const url = this.element.dataset.shareUrl
    navigator.clipboard.writeText(url).then(() => {
      const tooltip = bootstrap.Tooltip.getInstance(document.querySelector('[data-bs-toggle="tooltip"]'))
      const originalTitle = tooltip._config.title
      tooltip.setContent({ '.tooltip-inner': 'Link copied!' })
      setTimeout(() => {
        tooltip.setContent({ '.tooltip-inner': originalTitle })
      }, 2000)
    })
  }
  
  copyToClipboard(event) {
    const text = event.currentTarget.dataset.copyText
    navigator.clipboard.writeText(text).then(() => {
      console.log('Text copied to clipboard')
    }).catch(err => {
      console.error('Failed to copy text: ', err)
    })
  }
  
  startPolling() {
    this.pollInterval = setInterval(() => {
      fetch(this.element.dataset.pollUrl)
        .then(response => response.json())
        .then(data => {
          if (data.status === 'completed') {
            clearInterval(this.pollInterval)
            window.location.reload()
          }
        })
    }, 2000)
  }
  
  disconnect() {
    if (this.pollInterval) {
      clearInterval(this.pollInterval)
    }
  }
} 