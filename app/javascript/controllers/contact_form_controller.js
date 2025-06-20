import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Bootstrap is available globally when loaded via importmap
    this.modal = new bootstrap.Modal(document.getElementById('contactModal'))
    this.setupFormValidation()
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

    async handleSubmit(event) {
    console.log('handleSubmit called, preventing default...')
    event.preventDefault()
    event.stopPropagation()

    const form = event.target
    console.log('Form:', form)

    if (!form.checkValidity()) {
      console.log('Form validation failed')
      form.classList.add('was-validated')
      return
    }

    console.log('Form is valid, proceeding with fetch...')

    const submitButton = form.querySelector('#sendButton')
    submitButton.disabled = true
    submitButton.textContent = 'Sending...'

    try {
      const formData = new FormData(form)
      const response = await fetch(form.action, {
        method: 'POST',
        body: formData,
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
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

        handleSuccess(data) {
    console.log('Contact form success:', data)

    // Show success message
    this.showMessage('Message sent successfully! I\'ll get back to you soon.', 'success')

    // Reset form
    const form = document.getElementById('contactForm')
    form.reset()
    form.classList.remove('was-validated')

        // Close modal after a short delay
    setTimeout(() => {
      console.log('Timer fired - attempting to close modal...')
      const modalElement = document.getElementById('contactModal')

      // Direct approach: trigger Bootstrap's data attribute
      modalElement.querySelector('[data-bs-dismiss="modal"]').click()

      console.log('Modal close attempted via button click')
    }, 1500)
  }

  handleError(data) {
    console.log('Contact form error:', data)
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
