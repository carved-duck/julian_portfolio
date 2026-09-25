import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.boundListeners = []

    // Bootstrap is available globally when loaded via importmap
    this.modal = new bootstrap.Modal(document.getElementById('contactModal'))
    this.setupFormValidation()
    this.formStartTime = Date.now()

    // Log form interaction for timing analysis
    this.setupInteractionTracking()

    // Track analytics when modal opens
    const modalElement = document.getElementById('contactModal')
    this.addListener(modalElement, 'shown.bs.modal', () => {
      if (typeof window.trackContactFormOpen === 'function') {
        window.trackContactFormOpen()
      }
    })
  }

  disconnect() {
    // Tear down every listener bound in connect() so nothing leaks across Turbo navigations
    this.boundListeners.forEach(({ element, type, handler }) => {
      element.removeEventListener(type, handler)
    })
    this.boundListeners = []
  }

  addListener(element, type, handler) {
    element.addEventListener(type, handler)
    this.boundListeners.push({ element, type, handler })
  }

  setupFormValidation() {
    const forms = document.querySelectorAll('.needs-validation')
    Array.from(forms).forEach(form => {
      this.addListener(form, 'submit', event => {
        if (!form.checkValidity()) {
          event.preventDefault()
          event.stopPropagation()
        }
        form.classList.add('was-validated')
      })
    })
  }

  setupInteractionTracking() {
    // Track if user actually interacts with form fields (not just programmatically fills them)
    this.hasUserInteraction = false
    const form = document.getElementById('contactForm')
    const realFields = form.querySelectorAll('input[name="name"], input[name="email"], input[name="subject"], textarea[name="message"]')

    const markInteraction = () => { this.hasUserInteraction = true }
    realFields.forEach(field => {
      this.addListener(field, 'keydown', markInteraction)
      this.addListener(field, 'focus', markInteraction)
      this.addListener(field, 'paste', markInteraction)
    })
  }

  async handleSubmit(event) {
    event.preventDefault()
    event.stopPropagation()

    const form = event.target

    // Client-side bot detection
    if (this.detectBotBehavior()) {
      this.handleError({ message: 'Please try again later.' })
      return
    }

    if (!form.checkValidity()) {
      form.classList.add('was-validated')
      return
    }

    const submitButton = form.querySelector('#sendButton')
    submitButton.disabled = true
    submitButton.textContent = 'Sending...'

    try {
      const formData = new FormData(form)

      // Add client-side timing info
      const submissionTime = Date.now()
      const timeTaken = submissionTime - this.formStartTime
      formData.append('client_timing', timeTaken)
      formData.append('has_interaction', this.hasUserInteraction)

      const response = await fetch(form.action, {
        method: 'POST',
        body: formData,
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          'X-Requested-With': 'XMLHttpRequest'
        }
      })

      const result = await response.json()

      if (response.ok && result.status === 'success') {
        this.handleSuccess(result)
      } else {
        this.handleError(result)
      }
    } catch (error) {
      console.error('Form submission error:', error)
      this.handleError({ message: 'Network error. Please try again.' })
    } finally {
      submitButton.disabled = false
      submitButton.textContent = 'Send Message'
    }
  }

  detectBotBehavior() {
    const form = document.getElementById('contactForm')

    // Check if honeypot fields are filled
    const honeypotFields = ['website', 'url', 'company_website', 'phone_number']
    for (const fieldName of honeypotFields) {
      const field = form.querySelector(`[name="${fieldName}"]`)
      if (field && field.value.trim() !== '') {
        return true
      }
    }

    // Check if form was submitted too quickly (less than 2 seconds)
    const timeTaken = Date.now() - this.formStartTime
    if (timeTaken < 2000) {
      return true
    }

    // Check if user never interacted with form
    if (!this.hasUserInteraction) {
      return true
    }

    // Check for suspicious patterns in the message
    const messageField = form.querySelector('[name="message"]')
    if (messageField) {
      const message = messageField.value.toLowerCase()

      // Check for common spam patterns
      const spamPatterns = [
        /https?:\/\/.*https?:\/\//, // Multiple URLs
        /seo.*ranking.*google/i,
        /website.*design.*affordable/i,
        /traffic.*increase.*guaranteed/i
      ]

      if (spamPatterns.some(pattern => pattern.test(message))) {
        return true
      }
    }

    return false
  }

  handleSuccess(data) {
    // Track successful submission
    if (typeof window.trackContactFormSubmit === 'function') {
      window.trackContactFormSubmit()
    }

    // Show success message
    this.showMessage('Message sent successfully! I\'ll get back to you soon.', 'success')

    // Reset form
    const form = document.getElementById('contactForm')
    form.reset()
    form.classList.remove('was-validated')

    // Reset interaction tracking
    this.hasUserInteraction = false
    this.formStartTime = Date.now()

    // Close modal after a short delay
    setTimeout(() => {
      const modalElement = document.getElementById('contactModal')

      // Direct approach: trigger Bootstrap's data attribute
      modalElement.querySelector('[data-bs-dismiss="modal"]').click()
    }, 1500)
  }

  handleError(data) {
    const message = data.message || 'Failed to send message. Please try again.'
    this.showMessage(message, 'error')
  }

  showMessage(message, type) {
    // Remove any existing messages
    const existingMessage = document.querySelector('.contact-message')
    if (existingMessage) {
      existingMessage.remove()
    }

    // Create and show new message
    const messageDiv = document.createElement('div')
    messageDiv.className = `alert ${type === 'success' ? 'alert-success' : 'alert-danger'} contact-message`
    messageDiv.textContent = message

    const modalBody = document.querySelector('#contactModal .modal-body')
    modalBody.insertBefore(messageDiv, modalBody.firstChild)

    // Auto-remove message after 3 seconds
    setTimeout(() => {
      if (messageDiv.parentNode) {
        messageDiv.remove()
      }
    }, 3000)
  }
}
