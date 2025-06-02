import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["feedbackInput"]

  connect() {
    console.log('Feedback controller connected')
    this.element.addEventListener('submit', this.handleSubmit.bind(this))
    
    // Get the section from the form's hidden input
    const sectionInput = this.element.querySelector('input[name="section"]')
    const section = sectionInput ? sectionInput.value : null
    console.log('Section:', section)
    
    // Check if any rating button is active
    const activeButton = this.element.querySelector('button[name="rating"].active')
    console.log('Active button found:', activeButton?.value)
    
    // Show feedback input if there's an active rating
    if (this.hasFeedbackInputTarget) {
      const shouldShow = activeButton !== null
      console.log('Should show feedback input:', shouldShow)
      this.feedbackInputTarget.style.display = shouldShow ? 'flex' : 'none'
    }
  }

  handleSubmit(event) {
    event.preventDefault()
    console.log('Form submitted')
   
    const form = event.target
    const formData = new FormData(form)
    const submitButton = event.submitter
    const section = formData.get('section')
    console.log(`Submit button clicked for section ${section}:`, submitButton?.name, submitButton?.value)

    // If a thumbs button was clicked, update the rating
    if (submitButton && submitButton.name === 'rating') {
      formData.set('rating', submitButton.value)
      // Update button states
      const buttons = form.querySelectorAll('button[name="rating"]')
      buttons.forEach(button => {
        button.classList.remove('active')
        if (button === submitButton) {
          button.classList.add('active')
        }
      })
      // Show/hide feedback input based on active state
      if (this.hasFeedbackInputTarget) {
        const isActive = submitButton.classList.contains('active')
        console.log('Setting feedback input display:', isActive ? 'flex' : 'none')
        this.feedbackInputTarget.style.display = isActive ? 'flex' : 'none'
      }
    } else {
      // If it's the feedback submit button, keep the current rating
      const activeButton = form.querySelector('button[name="rating"].active')
      if (activeButton) {
        formData.set('rating', activeButton.value)
      }
    }

    fetch(form.action, {
      method: 'POST',
      body: formData,
      headers: {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      },
      credentials: 'same-origin'
    })
    .then(response => response.json())
    .then(data => {
      if (data.status === 'success') {
        this.showToast('success', 'Thank you for your feedback!')
      } else {
        this.showToast('error', data.message || 'Could not save feedback. Please try again.')
      }
    })
    .catch(error => {
      console.error(`Fetch error for section ${section}:`, error)
      this.showToast('error', 'Could not save feedback. Please try again.')
    })
  }

  showToast(type, message) {
    const toast = document.createElement('div')
    toast.className = 'toast show position-fixed bottom-0 end-0 m-3'
    toast.innerHTML = `
      <div class="toast-header ${type === 'error' ? 'bg-danger text-white' : ''}">
        <strong class="me-auto">${type === 'error' ? 'Error' : 'Success'}</strong>
        <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
      </div>
      <div class="toast-body">
        ${message}
      </div>
    `
    document.body.appendChild(toast)
    setTimeout(() => toast.remove(), 3000)
  }
} 