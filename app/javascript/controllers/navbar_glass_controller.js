import { Controller } from "@hotwired/stimulus"

// Watches a sentinel element; when it exits viewport, adds glass effect to navbar.
// Usage:
//   <nav data-controller="navbar-glass" data-navbar-glass-sentinel-value="#hero-sentinel">
export default class extends Controller {
  static values = {
    sentinel: { type: String, default: "#hero-sentinel" }
  }

  connect() {
    this.sentinelEl = document.querySelector(this.sentinelValue)
    if (!this.sentinelEl) return

    this.observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          this.element.classList.remove("is-glass")
          this.element.classList.add("is-transparent")
        } else {
          this.element.classList.add("is-glass")
          this.element.classList.remove("is-transparent")
        }
      },
      { threshold: 0 }
    )

    this.observer.observe(this.sentinelEl)
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }
}
