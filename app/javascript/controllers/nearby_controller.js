import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["status"]

  find() {
    if (!navigator.geolocation) {
      this.statusTarget.textContent = "Your browser does not support location. Browse cinemas instead."
      return
    }
    this.statusTarget.textContent = "Finding your location…"
    navigator.geolocation.getCurrentPosition(
      ({ coords }) => { window.location.href = `/cinemas?near=${coords.latitude},${coords.longitude}` },
      () => { this.statusTarget.textContent = "Location unavailable. You can still browse all cinemas." },
      { timeout: 10000, maximumAge: 300000 }
    )
  }
}
