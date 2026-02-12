import { Controller } from "@hotwired/stimulus"

// Enables mouse drag-to-scroll on a horizontal container (desktop).
// Touch scrolling is native. Only activates drag on non-touch pointerdown.
// Usage:
//   <div data-controller="drag-scroll" class="overflow-x-auto">
export default class extends Controller {
  connect() {
    this.isDown = false
    this.startX = 0
    this.scrollLeft = 0

    this.onPointerDown = this.onPointerDown.bind(this)
    this.onPointerMove = this.onPointerMove.bind(this)
    this.onPointerUp = this.onPointerUp.bind(this)

    this.element.addEventListener("pointerdown", this.onPointerDown)
    this.element.addEventListener("pointermove", this.onPointerMove)
    this.element.addEventListener("pointerup", this.onPointerUp)
    this.element.addEventListener("pointerleave", this.onPointerUp)
  }

  disconnect() {
    this.element.removeEventListener("pointerdown", this.onPointerDown)
    this.element.removeEventListener("pointermove", this.onPointerMove)
    this.element.removeEventListener("pointerup", this.onPointerUp)
    this.element.removeEventListener("pointerleave", this.onPointerUp)
  }

  onPointerDown(e) {
    // Only drag with mouse, not touch (touch has native scroll)
    if (e.pointerType === "touch") return

    this.isDown = true
    this.element.classList.add("is-dragging")
    this.startX = e.pageX - this.element.offsetLeft
    this.scrollLeft = this.element.scrollLeft
    this.element.setPointerCapture(e.pointerId)
  }

  onPointerMove(e) {
    if (!this.isDown) return
    e.preventDefault()
    const x = e.pageX - this.element.offsetLeft
    const walk = (x - this.startX) * 1.5
    this.element.scrollLeft = this.scrollLeft - walk
  }

  onPointerUp(e) {
    if (!this.isDown) return
    this.isDown = false
    this.element.classList.remove("is-dragging")
  }
}
