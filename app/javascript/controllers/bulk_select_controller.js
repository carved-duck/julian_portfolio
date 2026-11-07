import { Controller } from "@hotwired/stimulus"

// Admin guest list: "Select all", a live count on the "Remove selected" button, and a confirm
// message that names how many will go. Without JS the form still works; the server just reports
// when nothing was ticked.
export default class extends Controller {
  static targets = ["all", "item", "button"]
  static values = { event: String }

  connect() {
    this.refresh()
  }

  toggleAll() {
    this.itemTargets.forEach((box) => { box.checked = this.allTarget.checked })
    this.refresh()
  }

  refresh() {
    const ticked = this.itemTargets.filter((box) => box.checked).length
    const total = this.itemTargets.length
    const people = ticked === 1 ? "1 attendee" : `${ticked} attendees`

    this.allTarget.checked = ticked === total
    this.allTarget.indeterminate = ticked > 0 && ticked < total
    this.buttonTarget.disabled = ticked === 0
    this.buttonTarget.textContent = ticked === 0 ? "Remove selected" : `Remove ${people}`
    this.element.dataset.turboConfirm = `Remove ${people} from ${this.eventValue}? This can't be undone.`
  }
}
