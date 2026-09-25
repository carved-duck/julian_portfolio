import { Controller } from "@hotwired/stimulus"

// The home page's two doors (Photos, Dev work). Hovering a door opens its panel on devices with a
// mouse; a click, tap, Enter or Space opens it everywhere. One panel is open at a time.
//
// Each door is a <button data-showcase-target="door" data-key="photos">, each panel a
// <div data-showcase-target="panel" data-key="photos">. Panels share one grid cell in CSS, so the
// section keeps the taller panel's height and nothing below it jumps when they swap.
export default class extends Controller {
  static targets = ["door", "panel"]
  static values = { open: String }

  connect() {
    this.hoverMQ = window.matchMedia("(hover: hover) and (pointer: fine)")
    if (!this.openValue && this.doorTargets[0]) this.openValue = this.doorTargets[0].dataset.key
  }

  // mouseenter->showcase#hover
  hover(event) {
    if (this.hoverMQ.matches) this.openValue = event.currentTarget.dataset.key
  }

  // click->showcase#select
  select(event) {
    this.openValue = event.currentTarget.dataset.key
  }

  openValueChanged(key) {
    this.doorTargets.forEach((door) => {
      const open = door.dataset.key === key
      door.setAttribute("aria-expanded", open)
      door.classList.toggle("is-open", open)
    })
    this.panelTargets.forEach((panel) => {
      const open = panel.dataset.key === key
      panel.classList.toggle("is-open", open)
      panel.inert = !open
    })
  }
}
