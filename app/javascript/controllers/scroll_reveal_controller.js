import { Controller } from "@hotwired/stimulus"

// Toggles .is-revealed on observed elements when they enter the viewport.
// Supports data-reveal-delay for staggered reveals (in ms).
// Usage:
//   <div data-controller="scroll-reveal" data-scroll-reveal-threshold-value="0.15">
//     <h2 class="reveal-fade-up" data-reveal-delay="0">...</h2>
//     <p  class="reveal-fade-up" data-reveal-delay="80">...</p>
//     <a  class="reveal-fade-up" data-reveal-delay="160">...</a>
//   </div>
export default class extends Controller {
  static values = {
    threshold: { type: Number, default: 0.15 },
    once: { type: Boolean, default: true }
  }

  connect() {
    // Respect prefers-reduced-motion: reveal everything immediately
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      this.revealAll()
      return
    }

    this.observer = new IntersectionObserver(
      (entries) => this.handleIntersect(entries),
      { threshold: this.thresholdValue, rootMargin: "0px 0px -40px 0px" }
    )

    // Collect all [data-reveal-delay] children
    this.revealElements = this.element.querySelectorAll("[data-reveal-delay]")
    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  handleIntersect(entries) {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        this.revealStaggered()
        if (this.onceValue) this.observer.unobserve(entry.target)
      }
    })
  }

  revealStaggered() {
    if (this.revealElements && this.revealElements.length > 0) {
      this.revealElements.forEach((el) => {
        const delay = parseInt(el.dataset.revealDelay || "0", 10)
        setTimeout(() => el.classList.add("is-revealed"), delay)
      })
    } else {
      this.element.classList.add("is-revealed")
    }
  }

  revealAll() {
    this.element.classList.add("is-revealed")
    const els = this.element.querySelectorAll("[data-reveal-delay]")
    els.forEach((el) => el.classList.add("is-revealed"))
  }
}
