import { Controller } from "@hotwired/stimulus"

// Scroll-velocity parallax for hero blobs.
// Applies translate3d transforms based on scroll position and speed.
// Usage:
//   <section data-controller="hero-parallax">
//     <div data-hero-parallax-target="blob" data-parallax-speed="0.15">...</div>
//     <div data-hero-parallax-target="blob" data-parallax-speed="-0.08">...</div>
//   </section>
export default class extends Controller {
  static targets = ["blob"]

  connect() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return

    this.ticking = false
    this.lastScrollY = window.scrollY
    this.velocity = 0

    this.onScroll = this.onScroll.bind(this)
    window.addEventListener("scroll", this.onScroll, { passive: true })

    // Set will-change on blobs
    this.blobTargets.forEach((blob) => {
      blob.style.willChange = "transform"
    })

    // Remove will-change after initial load settles (free GPU memory)
    this.idleTimer = null
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
    if (this.rafId) cancelAnimationFrame(this.rafId)
    if (this.idleTimer) clearTimeout(this.idleTimer)

    this.blobTargets.forEach((blob) => {
      blob.style.willChange = ""
      blob.style.transform = ""
    })
  }

  onScroll() {
    if (!this.ticking) {
      this.rafId = requestAnimationFrame(() => {
        this.update()
        this.ticking = false
      })
      this.ticking = true
    }

    // Reset idle timer — remove will-change after 200ms of no scroll
    if (this.idleTimer) clearTimeout(this.idleTimer)
    this.idleTimer = setTimeout(() => {
      this.blobTargets.forEach((blob) => {
        blob.style.willChange = ""
      })
    }, 200)
  }

  update() {
    const scrollY = window.scrollY
    const delta = scrollY - this.lastScrollY
    // Smooth velocity (blend 30% of new delta)
    this.velocity = this.velocity * 0.7 + delta * 0.3
    this.lastScrollY = scrollY

    // Restore will-change during active scrolling
    this.blobTargets.forEach((blob) => {
      blob.style.willChange = "transform"

      const speed = parseFloat(blob.dataset.parallaxSpeed || "0.1")
      const baseY = scrollY * speed
      // Velocity adds a "reactive" extra offset (scaled down)
      const reactiveOffset = this.velocity * speed * 2

      blob.style.transform = `translate3d(0, ${baseY + reactiveOffset}px, 0)`
    })
  }
}
