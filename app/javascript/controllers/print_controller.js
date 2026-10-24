import { Controller } from "@hotwired/stimulus"

// Opens the browser's native print preview.
// Bind a button with data-action="click->print#print".
export default class extends Controller {
  print() {
    window.print()
  }
}
