import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["nextButton", "prevButton"]

  connect() {
    this.boundHandleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.boundHandleKeydown)

    // Update page title when frame loads
    this.element.addEventListener("turbo:frame-load", this.updatePageTitle.bind(this))

    // Add touch support for mobile
    this.setupTouchNavigation()
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandleKeydown)
  }

  handleKeydown(event) {
    // Only handle if not typing in an input field
    if (event.target.tagName === "INPUT" || event.target.tagName === "TEXTAREA") {
      return
    }

    switch(event.key) {
      case "ArrowLeft":
        event.preventDefault()
        this.navigatePrevious()
        break
      case "ArrowRight":
        event.preventDefault()
        this.navigateNext()
        break
      case "Escape":
        event.preventDefault()
        this.goBack()
        break
    }
  }

  navigateNext() {
    if (this.hasNextButtonTarget && !this.nextButtonTarget.classList.contains("disabled")) {
      this.nextButtonTarget.click()
    }
  }

  navigatePrevious() {
    if (this.hasPrevButtonTarget && !this.prevButtonTarget.classList.contains("disabled")) {
      this.prevButtonTarget.click()
    }
  }

  goBack() {
    const backButton = document.querySelector('a[href*="photos"]:not([data-turbo-frame])')
    if (backButton) {
      backButton.click()
    }
  }

  updatePageTitle() {
    // Extract category from the current photo display
    const categoryElement = this.element.querySelector('h2')
    if (categoryElement) {
      const categoryText = categoryElement.textContent.trim()
      const category = categoryText.split(' taken in')[0] // Remove location part if present
      document.title = `${category} Photos | Julian Schoenfeld`
    }
  }

  setupTouchNavigation() {
    const photoImage = this.element.querySelector('.photo-main-image')
    if (!photoImage) return

    let startX = null
    let startY = null

    photoImage.addEventListener('touchstart', (e) => {
      startX = e.touches[0].clientX
      startY = e.touches[0].clientY
    }, { passive: true })

    photoImage.addEventListener('touchend', (e) => {
      if (!startX || !startY) return

      const endX = e.changedTouches[0].clientX
      const endY = e.changedTouches[0].clientY

      const diffX = startX - endX
      const diffY = startY - endY

      // Only trigger if horizontal swipe is dominant and significant
      if (Math.abs(diffX) > Math.abs(diffY) && Math.abs(diffX) > 50) {
        if (diffX > 0) {
          // Swiped left - go to next photo
          this.navigateNext()
        } else {
          // Swiped right - go to previous photo
          this.navigatePrevious()
        }
      }

      startX = null
      startY = null
    }, { passive: true })
  }
}
