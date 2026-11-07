import { Controller } from "@hotwired/stimulus"

// Event signup form: shows the "What are you bringing?" text box only while "Other" is picked.
// A Stimulus controller, not an inline script, so it also runs after Turbo visits and after a
// failed submit re-renders the form.
export default class extends Controller {
  static targets = ["select", "other"]
  static values = { choice: String }

  connect() {
    this.toggle()
  }

  toggle() {
    this.otherTarget.hidden = this.selectTarget.value !== this.choiceValue
  }
}
