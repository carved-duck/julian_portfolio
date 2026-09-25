import { Controller } from "@hotwired/stimulus"

// Photos page: a tap on a contact-sheet frame (or "Back to the contact sheet") glides to its
// target. Only these links scroll smoothly; page-wide smooth scrolling is off
// ($enable-smooth-scroll) because it would also animate Turbo's restore scrolls (Back, or
// returning from a photo). Instant under reduced motion. The URL hash still updates, so the spot survives a reload.
export default class extends Controller {
  jump(event) {
    const link = event.currentTarget
    const target = document.getElementById(link.hash.slice(1))
    if (!target) return

    event.preventDefault()
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches
    target.scrollIntoView({ behavior: reduce ? "instant" : "smooth", block: "start" })
    history.replaceState(history.state, "", link.hash)
  }
}
