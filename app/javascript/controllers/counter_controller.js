import { Controller } from "@hotwired/stimulus"

// Counts a number from 0 to target when the element enters the viewport.
// Usage:
//   <span data-controller="counter" data-counter-target-value="200" data-counter-suffix-value="+">0</span>
export default class extends Controller {
  static values = {
    target: { type: Number, default: 0 },
    duration: { type: Number, default: 1500 },
    suffix: { type: String, default: "" },
    prefix: { type: String, default: "" }
  }

  connect() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      this.element.textContent = this.prefixValue + this.targetValue.toLocaleString() + this.suffixValue
      return
    }

    this.hasRun = false
    this.observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting && !this.hasRun) {
          this.hasRun = true
          this.animate()
          this.observer.unobserve(this.element)
        }
      },
      { threshold: 0.3 }
    )
    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
    if (this.rafId) cancelAnimationFrame(this.rafId)
  }

  animate() {
    const target = this.targetValue
    const duration = this.durationValue
    const start = performance.now()

    const step = (now) => {
      const elapsed = now - start
      const progress = Math.min(elapsed / duration, 1)
      // Deceleration easing (ease-out)
      const eased = 1 - Math.pow(1 - progress, 3)
      const current = Math.round(eased * target)

      this.element.textContent = this.prefixValue + current.toLocaleString() + this.suffixValue

      if (progress < 1) {
        this.rafId = requestAnimationFrame(step)
      }
    }

    this.rafId = requestAnimationFrame(step)
  }
}
