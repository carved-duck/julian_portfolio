import { Controller } from "@hotwired/stimulus"

// A row of cards that scrolls sideways. The browser does the work: the track is a horizontal
// scroll container with CSS scroll-snap, so swiping on a phone and trackpad scrolling just work.
// The arrows scroll by one card, and each one is disabled when there is nothing more that way.
export default class extends Controller {
  static targets = ["track", "prev", "next"]

  connect() {
    this.onScroll = () => this.updateArrows()
    this.trackTarget.addEventListener("scroll", this.onScroll, { passive: true })
    this.resizeObserver = new ResizeObserver(this.onScroll)
    this.resizeObserver.observe(this.trackTarget)
    this.updateArrows()
  }

  disconnect() {
    this.trackTarget.removeEventListener("scroll", this.onScroll)
    this.resizeObserver.disconnect()
  }

  next() { this.scrollByCard(1) }
  prev() { this.scrollByCard(-1) }

  scrollByCard(direction) {
    const card = this.trackTarget.firstElementChild
    if (!card) return
    const gap = parseFloat(getComputedStyle(this.trackTarget).columnGap) || 0
    const smooth = !window.matchMedia("(prefers-reduced-motion: reduce)").matches
    this.trackTarget.scrollBy({ left: direction * (card.offsetWidth + gap), behavior: smooth ? "smooth" : "auto" })
  }

  updateArrows() {
    const { scrollLeft, scrollWidth, clientWidth } = this.trackTarget
    const slack = 4 // px: snapping and sub-pixel widths can leave the row a hair off either end
    this.element.classList.toggle("slider--fits", scrollWidth <= clientWidth + slack)
    if (this.hasPrevTarget) this.prevTarget.disabled = scrollLeft <= slack
    if (this.hasNextTarget) this.nextTarget.disabled = scrollLeft + clientWidth >= scrollWidth - slack
  }
}
