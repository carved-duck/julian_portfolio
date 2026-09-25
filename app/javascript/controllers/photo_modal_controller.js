import { Controller } from "@hotwired/stimulus"

// Full-screen photo viewer (Home's featured photos, the Photos page's strip and grid). The link that
// opens the Bootstrap modal carries the image URL in data-photo-url. The arrows, arrow keys and a
// sideways swipe step through every photo those links point to, once each in page order (the
// Photos page links each photo twice: strip and grid).
export default class extends Controller {
  static targets = ["image", "prev", "next"]

  connect() {
    this.onShow = (event) => {
      const seen = new Map()
      document.querySelectorAll('[data-bs-target="#photoModal"][data-photo-url]').forEach((link) => {
        if (!seen.has(link.dataset.photoUrl)) seen.set(link.dataset.photoUrl, link.dataset.photoAlt)
      })
      this.photos = [...seen].map(([url, alt]) => ({ url, alt }))
      this.show(this.photos.findIndex((p) => p.url === event.relatedTarget?.dataset.photoUrl))
    }
    // Leaving the page with the viewer open (browser Back) would otherwise cache it open, with the
    // backdrop and a locked body, and restore it that way.
    this.onBeforeCache = () => {
      window.bootstrap?.Modal.getInstance(this.element)?.dispose()
      this.element.classList.remove("show")
      this.element.style.display = "none"
      document.querySelectorAll(".modal-backdrop").forEach((el) => el.remove())
      document.body.classList.remove("modal-open")
      document.body.removeAttribute("style")
    }
    this.onTouchStart = (event) => { this.touchX = event.touches[0].clientX }
    this.onTouchEnd = (event) => {
      if (this.touchX === undefined) return
      const dx = event.changedTouches[0].clientX - this.touchX
      this.touchX = undefined
      if (Math.abs(dx) > 50) dx < 0 ? this.next() : this.prev()
    }
    this.element.addEventListener("show.bs.modal", this.onShow)
    this.element.addEventListener("touchstart", this.onTouchStart, { passive: true })
    this.element.addEventListener("touchend", this.onTouchEnd)
    document.addEventListener("turbo:before-cache", this.onBeforeCache)
  }

  disconnect() {
    this.element.removeEventListener("show.bs.modal", this.onShow)
    this.element.removeEventListener("touchstart", this.onTouchStart)
    this.element.removeEventListener("touchend", this.onTouchEnd)
    document.removeEventListener("turbo:before-cache", this.onBeforeCache)
  }

  prev() { this.show(this.index - 1) }
  next() { this.show(this.index + 1) }

  key(event) {
    if (event.key === "ArrowLeft") this.prev()
    if (event.key === "ArrowRight") this.next()
  }

  show(index) {
    const photo = this.photos?.[index]
    if (!photo) return
    this.index = index
    this.imageTarget.src = photo.url
    this.imageTarget.alt = photo.alt || "Photo"
    this.prevTarget.classList.toggle("is-hidden", index === 0)
    this.nextTarget.classList.toggle("is-hidden", index === this.photos.length - 1)

    // A hidden arrow drops keyboard focus to <body>, where ←/→ and Escape stop working.
    const focused = document.activeElement
    if (focused?.classList.contains("is-hidden")) {
      const other = focused === this.prevTarget ? this.nextTarget : this.prevTarget
      other.classList.contains("is-hidden") ? this.element.focus() : other.focus()
    }
  }
}
