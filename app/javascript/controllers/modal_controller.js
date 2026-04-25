import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  open() {
    this.element.style.display = "flex"
  }

  close() {
    this.element.style.display = "none"
    this.element.remove()
  }

  closeOnBackdrop(event) {
    if (event.target === this.element) {
      this.close()
    }
  }
}
