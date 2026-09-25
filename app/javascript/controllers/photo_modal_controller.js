import { Controller } from "@hotwired/stimulus"

// Full-screen photo viewer. The link that opens the Bootstrap modal carries the image URL in
// data-photo-url; this puts it into the modal's <img> as the modal opens.
export default class extends Controller {
  static targets = ["image"]

  connect() {
    this.onShow = (event) => {
      const trigger = event.relatedTarget
      if (!trigger?.dataset.photoUrl) return
      this.imageTarget.src = trigger.dataset.photoUrl
      this.imageTarget.alt = trigger.dataset.photoAlt || "Photo"
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
}
