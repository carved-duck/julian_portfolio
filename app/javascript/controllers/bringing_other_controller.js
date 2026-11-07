import { Controller } from "@hotwired/stimulus"

// Event signup form: shows the "What are you bringing?" text box only while "Something else" is
// picked. A Stimulus controller, not an inline script, so it also runs after Turbo visits and after
// a failed submit re-renders the form.
export default class extends Controller {
  static targets = ["other"]
  static values = { choice: String }

  connect() {
    this.toggle()
  }

  toggle() {
    // BBQ events and events without dish categories render the form with no picker.
    if (!this.hasOtherTarget) return

    const picked = this.element.querySelector('input[name="attendee[bringing]"]:checked')
    this.otherTarget.hidden = picked?.value !== this.choiceValue
  }
}
