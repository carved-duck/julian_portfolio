import { Controller } from "@hotwired/stimulus"

// Full-screen photo viewer for Home. The link that opens the Bootstrap modal carries the image URL
// in data-photo-url; the arrows (and arrow keys) step through every such link on the page.
export default class extends Controller {
  static targets = ["image", "prev", "next"]

  connect() {
    this.onShow = (event) => {
      this.triggers = [...document.querySelectorAll('[data-bs-target="#photoModal"][data-photo-url]')]
      this.show(this.triggers.indexOf(event.relatedTarget))
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
    this.element.addEventListener("show.bs.modal", this.onShow)
    document.addEventListener("turbo:before-cache", this.onBeforeCache)
  }

  disconnect() {
    this.element.removeEventListener("show.bs.modal", this.onShow)
    document.removeEventListener("turbo:before-cache", this.onBeforeCache)
  }

  prev() { this.show(this.index - 1) }
  next() { this.show(this.index + 1) }

  key(event) {
    if (event.key === "ArrowLeft") this.prev()
    if (event.key === "ArrowRight") this.next()
  }

  show(index) {
    const trigger = this.triggers?.[index]
    if (!trigger) return
    this.index = index
    this.imageTarget.src = trigger.dataset.photoUrl
    this.imageTarget.alt = trigger.dataset.photoAlt || "Photo"
    this.prevTarget.classList.toggle("is-hidden", index === 0)
    this.nextTarget.classList.toggle("is-hidden", index === this.triggers.length - 1)
  }
}
