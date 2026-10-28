import { Controller } from "@hotwired/stimulus"

// Floats elements marked data-wind on the billow from seigaiha_controller, like things resting on
// cloth the wind lifts: each rises with the cloth under it, tilts toward whichever side sits
// higher, and is carried a hair downwind, then settles. What gets the mark, and the CSS rules a
// marked element must follow: docs/frontend.md § Wind.
export default class extends Controller {
  static values = {
    rise: { type: Number, default: 5 },  // max lift, px
    carry: { type: Number, default: 2 }, // max slide downwind, px
    tilt: { type: Number, default: 1.5 } // max tilt, degrees
  }

  connect() {
    this.billow = null
    this.offsets = new Map() // element -> { x, y, rot } for everything not at rest
    this.held = new Set()    // hovered or focused during this billow: stays still until it ends
    this.visible = new Set()
    this.rafId = null
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return

    this.observer = new IntersectionObserver((entries) => {
      for (const entry of entries) {
        if (entry.isIntersecting) this.visible.add(entry.target)
        else this.visible.delete(entry.target)
      }
    })
    document.querySelectorAll("[data-wind]").forEach((el) => this.observer.observe(el))

    // Turbo snapshots the page for the Back button before disconnect() runs; settle cards first.
    this.onBeforeCache = () => this.settleAll()
    this.onVisibility = () => this.wake()
    document.addEventListener("turbo:before-cache", this.onBeforeCache)
    document.addEventListener("visibilitychange", this.onVisibility)
  }

  disconnect() {
    this.observer?.disconnect()
    document.removeEventListener("turbo:before-cache", this.onBeforeCache)
    document.removeEventListener("visibilitychange", this.onVisibility)
    this.settleAll()
  }

  ride({ detail }) {
    if (!this.observer) return
    this.billow = detail
    this.wake()
  }

  calm() {
    this.billow = null
    this.held.clear()
    this.wake()
  }

  wake() {
    if (this.rafId === null && !document.hidden) this.rafId = requestAnimationFrame(() => this.frame())
  }

  frame() {
    this.rafId = null
    const now = performance.now()

    // Read every position first, then write, so the browser lays out the page once per frame.
    const elements = new Set([...this.visible, ...this.offsets.keys()])
    const targets = new Map()
    for (const el of elements) targets.set(el, this.targetFor(el, now))

    let moving = false
    for (const [el, target] of targets) {
      const resting = target === REST
      if (resting && !this.offsets.has(el)) continue

      const o = this.offsets.get(el) || { x: 0, y: 0, rot: 0 }
      o.x += (target.x - o.x) * EASE
      o.y += (target.y - o.y) * EASE
      o.rot += (target.rot - o.rot) * EASE

      const settled = Math.abs(o.x) < 0.05 && Math.abs(o.y) < 0.05 && Math.abs(o.rot) < 0.01
      if (resting && settled) {
        this.offsets.delete(el)
        clearFloat(el)
        continue
      }
      this.offsets.set(el, o)
      el.style.translate = `${o.x.toFixed(2)}px ${o.y.toFixed(2)}px`
      el.style.rotate = `${o.rot.toFixed(3)}deg`
      moving = true
    }
    if (moving || this.billow) this.wake()
  }

  // Where the cloth under this element wants it right now.
  targetFor(el, now) {
    const billow = this.billow
    if (!billow || !this.visible.has(el) || this.held.has(el)) return REST
    // Holding for the rest of the billow stops a card that floats under a resting cursor from
    // flickering between hovered and not.
    if (el.matches(":hover, :focus-within")) {
      this.held.add(el)
      return REST
    }
    // Skips cards inside a hidden panel, which the IntersectionObserver still counts as on screen.
    if (el.checkVisibility && !el.checkVisibility({ visibilityProperty: true })) return REST

    const rect = el.getBoundingClientRect()
    const y = rect.top + rect.height / 2
    const inset = rect.width * 0.2
    const left = billow.sample(rect.left + inset, y, now).lift
    const middle = billow.sample(rect.left + rect.width / 2, y, now).lift
    const right = billow.sample(rect.right - inset, y, now).lift
    if (Math.max(Math.abs(left), Math.abs(middle), Math.abs(right)) < 0.01) return REST

    return {
      x: billow.dirX * this.carryValue * middle,
      y: billow.dirY * this.carryValue * middle - this.riseValue * middle,
      rot: (left - right) * this.tiltValue // CSS rotate turns clockwise, so a higher right side is negative
    }
  }

  settleAll() {
    cancelAnimationFrame(this.rafId)
    this.rafId = null
    for (const el of this.offsets.keys()) clearFloat(el)
    this.offsets.clear()
  }
}

const EASE = 0.1 // share of the remaining distance covered each frame
const REST = Object.freeze({ x: 0, y: 0, rot: 0 })

function clearFloat(el) {
  el.style.translate = ""
  el.style.rotate = ""
}
