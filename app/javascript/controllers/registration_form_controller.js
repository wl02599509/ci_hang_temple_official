import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { activityId: Number }
  static targets = ["searchInput"]

  connect() {
    this.selectedRegistrationIds = new Set()
    this.searchTimeout = null
  }

  updateSelection(event) {
    const checkbox = event.target
    const id = parseInt(checkbox.value)
    if (checkbox.checked) {
      this.selectedRegistrationIds.add(id)
    } else {
      this.selectedRegistrationIds.delete(id)
    }
  }

  toggleAll(event) {
    const checkboxes = this.element.querySelectorAll("tbody input[type=checkbox]")
    checkboxes.forEach(cb => {
      cb.checked = event.target.checked
      const id = parseInt(cb.value)
      if (event.target.checked) {
        this.selectedRegistrationIds.add(id)
      } else {
        this.selectedRegistrationIds.delete(id)
      }
    })
  }

  openRegisterModal() {
    const frame = document.getElementById("register_modal_frame")
    if (frame) {
      frame.src = `/admin/activities/${this.activityIdValue}/registrations/new_modal`
    }
  }

  openPayModal() {
    const ids = Array.from(this.selectedRegistrationIds)
    if (ids.length === 0) return

    const frame = document.getElementById("pay_modal_frame")
    if (frame) {
      const params = new URLSearchParams()
      ids.forEach(id => params.append("registration_ids[]", id))
      frame.src = `/admin/activities/${this.activityIdValue}/registrations/pay_modal?${params}`
    }
  }

  openCancelModal() {
    const ids = Array.from(this.selectedRegistrationIds)
    if (ids.length === 0) return

    const checkboxes = this.element.querySelectorAll("tbody input[type=checkbox]:checked")
    const hasPaid = Array.from(checkboxes).some(cb => cb.dataset.userStatus === "paid")
    const hasPending = Array.from(checkboxes).some(cb => cb.dataset.userStatus === "pending")

    const frame = document.getElementById("cancel_modal_frame")
    if (frame) {
      const params = new URLSearchParams()
      ids.forEach(id => params.append("registration_ids[]", id))
      if (hasPaid) params.set("has_paid", "1")
      if (hasPaid && hasPending) params.set("has_mixed", "1")
      frame.src = `/admin/activities/${this.activityIdValue}/registrations/cancel_modal?${params}`
    }
  }

  debounceSearch(event) {
    clearTimeout(this.searchTimeout)
    this.searchTimeout = setTimeout(() => {
      this.performSearch(event.target.value)
    }, 300)
  }

  performSearch(query) {
    const frame = document.getElementById("user_search_results")
    if (!frame) return

    const params = new URLSearchParams()
    params.set("q", query)
    frame.src = `/admin/activities/${this.activityIdValue}/registrations/user_search?${params}`
  }
}
