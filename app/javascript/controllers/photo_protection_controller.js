import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image"]

    connect() {
    this.element.addEventListener('contextmenu', this.preventRightClick.bind(this))
    this.element.addEventListener('dragstart', this.preventDrag.bind(this))
    this.element.addEventListener('selectstart', this.preventSelect.bind(this))

    // Disable right-click on all images in this element
    const images = this.element.querySelectorAll('img')
    images.forEach(img => {
      img.addEventListener('contextmenu', this.preventRightClick.bind(this))
      img.addEventListener('dragstart', this.preventDrag.bind(this))
      img.addEventListener('selectstart', this.preventSelect.bind(this))

      // Mobile-specific protection
      this.addMobileProtection(img)

      // Disable common keyboard shortcuts
      img.addEventListener('keydown', this.preventKeyboardShortcuts.bind(this))
    })

    // Disable keyboard shortcuts on the container
    this.element.addEventListener('keydown', this.preventKeyboardShortcuts.bind(this))
  }

  disconnect() {
    this.element.removeEventListener('contextmenu', this.preventRightClick.bind(this))
    this.element.removeEventListener('dragstart', this.preventDrag.bind(this))
    this.element.removeEventListener('selectstart', this.preventSelect.bind(this))
    this.element.removeEventListener('keydown', this.preventKeyboardShortcuts.bind(this))
  }

  preventRightClick(event) {
    event.preventDefault()
    return false
  }

  preventDrag(event) {
    event.preventDefault()
    return false
  }

  preventSelect(event) {
    event.preventDefault()
    return false
  }

    preventKeyboardShortcuts(event) {
    // Disable Ctrl+S (Save), Ctrl+A (Select All), Ctrl+C (Copy), etc.
    if (event.ctrlKey || event.metaKey) {
      if (event.key === 's' || event.key === 'a' || event.key === 'c' ||
          event.key === 'S' || event.key === 'A' || event.key === 'C') {
        event.preventDefault()
        return false
      }
    }

    // Disable F12 (Developer Tools)
    if (event.key === 'F12') {
      event.preventDefault()
      return false
    }
  }

  addMobileProtection(img) {
    // Prevent long-press context menu on mobile
    img.addEventListener('touchstart', this.preventLongPress.bind(this), { passive: false })
    img.addEventListener('touchend', this.preventLongPress.bind(this), { passive: false })
    img.addEventListener('touchcancel', this.preventLongPress.bind(this), { passive: false })

    // Prevent callout (iOS Safari image save popup)
    img.style.webkitTouchCallout = 'none'
    img.style.webkitUserSelect = 'none'

    // Add pointer events prevention for mobile
    img.addEventListener('pointerdown', this.preventPointerEvents.bind(this))
    img.addEventListener('pointerup', this.preventPointerEvents.bind(this))

    // Prevent image zoom/scaling on mobile
    img.addEventListener('gesturestart', this.preventGesture.bind(this))
    img.addEventListener('gesturechange', this.preventGesture.bind(this))
    img.addEventListener('gestureend', this.preventGesture.bind(this))
  }

  preventLongPress(event) {
    // Prevent long press context menu on mobile
    // BUT allow quick taps for navigation
    if (event.target.tagName === 'IMG') {
      const parentLink = event.target.closest('a')
      if (parentLink && (parentLink.classList.contains('photo-grid-item') || parentLink.href.includes('/photos/'))) {
        // For navigation images, only prevent long press, allow quick taps
        if (event.type === 'touchstart') {
          this.touchStartTime = Date.now()
          return true // Allow touch start for navigation
        } else if (event.type === 'touchend') {
          const touchDuration = Date.now() - this.touchStartTime
          if (touchDuration < 500) { // Quick tap (less than 500ms)
            return true // Allow navigation
          }
        }
      }
      event.preventDefault()
      event.stopPropagation()
      return false
    }
  }

  preventPointerEvents(event) {
    // Prevent pointer events that could lead to save actions
    // BUT allow navigation clicks (check if parent link exists)
    if (event.target.tagName === 'IMG') {
      const parentLink = event.target.closest('a')
      if (parentLink && (parentLink.classList.contains('photo-grid-item') || parentLink.href.includes('/photos/'))) {
        // Allow navigation clicks - don't prevent
        return true
      }
      event.preventDefault()
      return false
    }
  }

  preventGesture(event) {
    // Prevent pinch-to-zoom and other gestures on images
    event.preventDefault()
    return false
  }
}
