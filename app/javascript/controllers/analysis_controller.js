import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["section", "step", "nextButton", "prevButton"]
  
  connect() {
    this.currentSectionIndex = 0
    this.updateNavigation()
    
    // Initialize tooltips
    const tooltips = document.querySelectorAll('[data-bs-toggle="tooltip"]')
    tooltips.forEach(tooltip => new bootstrap.Tooltip(tooltip))
  }
  
  next() {
    if (this.currentSectionIndex < this.sectionTargets.length - 1) {
      this.currentSectionIndex++
      this.updateNavigation()
    }
  }
  
  previous() {
    if (this.currentSectionIndex > 0) {
      this.currentSectionIndex--
      this.updateNavigation()
    }
  }
  
  updateNavigation() {
    // Update section visibility
    this.sectionTargets.forEach((section, index) => {
      section.style.display = index === this.currentSectionIndex ? 'block' : 'none'
    })
    
    // Update step indicators
    this.stepTargets.forEach((step, index) => {
      if (index < this.currentSectionIndex) {
        step.classList.add('completed')
        step.classList.remove('active')
      } else if (index === this.currentSectionIndex) {
        step.classList.add('active')
        step.classList.remove('completed')
      } else {
        step.classList.remove('active', 'completed')
      }
    })
    
    // Update button states
    this.prevButtonTarget.disabled = this.currentSectionIndex === 0
    this.nextButtonTarget.disabled = this.currentSectionIndex === this.sectionTargets.length - 1
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
} 