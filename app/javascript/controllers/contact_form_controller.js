import { Controller } from "@hotwired/stimulus"
import { Modal } from "bootstrap"

export default class extends Controller {
  static targets = ["form", "submitButton", "name", "email", "subject", "message"]

  connect() {
    this.modal = new Modal(document.getElementById('contactModal'))
    this.form = document.getElementById('contactForm')
    this.setupFormValidation()
    this.setupFormSubmission()
  }

  setupFormValidation() {
    const forms = document.querySelectorAll('.needs-validation')
    Array.from(forms).forEach(form => {
      form.addEventListener('submit', event => {
        if (!form.checkValidity()) {
          event.preventDefault()
          event.stopPropagation()
        }
        form.classList.add('was-validated')
      }, false)
    })
  }

  setupFormSubmission() {
    this.form.addEventListener('ajax:success', (event) => {
      const [data, status, xhr] = event.detail
      this.handleSuccess(data)
    })

    this.form.addEventListener('ajax:error', (event) => {
      this.handleError()
    })
  }

  handleSuccess(data) {
    // Show success message
    this.showMessage('Message sent successfully! I\'ll get back to you soon.', 'success')

    // Reset form
    this.form.reset()
    this.form.classList.remove('was-validated')

    // Close modal after a short delay
    setTimeout(() => {
      this.modal.hide()
    }, 2000)
  }

  handleError() {
    this.showMessage('Failed to send message. Please try again or email me directly.', 'error')
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
