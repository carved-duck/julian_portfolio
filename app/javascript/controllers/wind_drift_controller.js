import { Controller } from "@hotwired/stimulus"
import { smoothstep } from "wind/math"

// Nudges anything marked data-wind a few pixels downwind while a gust (seigaiha_controller) passes
// over it, with the slightest tilt, then lets it settle back. Only glanceable things get the mark:
// cards, thumbnails, place buttons. Never text to read, and never the photo viewer.
// Whatever is under the mouse or holds keyboard focus stays still, so nobody chases a target.
// Cards follow the gust's overall direction, not its swirls, so they never drift against the wind.
// It writes the CSS `translate` and `rotate` properties, which stack on top of an element's own
// `transform`, so hover lifts keep working. Those elements must not transition `all`.
//
// Sits on the wave canvas, so it only runs on pages that have the waves:
// <canvas data-controller="seigaiha wind-drift" data-action="seigaiha:gust->wind-drift#push">
export default class extends Controller {
  static values = {
    reach: { type: Number, default: 180 }, // px from the gust that a card still feels it
    drift: { type: Number, default: 5 },   // max slide, px
    tilt: { type: Number, default: 1 }     // max tilt, degrees
  }

  connect() {
    this.gust = null
    this.gustAt = 0
    this.offsets = new Map() // element -> { x, y, rot } for everything not at rest
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
    document.addEventListener("turbo:before-cache", this.onBeforeCache)
  }

  disconnect() {
    this.observer?.disconnect()
    document.removeEventListener("turbo:before-cache", this.onBeforeCache)
    this.settleAll()
  }

  push({ detail }) {
    if (!this.observer) return
    this.gust = detail
    this.gustAt = performance.now()
    this.wake()
  }

  wake() {
    if (this.rafId === null && !document.hidden) this.rafId = requestAnimationFrame(() => this.frame())
  }

  frame() {
    this.rafId = null
    const now = performance.now()
    const gust = now - this.gustAt < 100 ? this.gust : null // no event lately: the gust has gone

    // Read every position first, then write, so the browser lays out the page once per frame.
    const elements = new Set([...this.visible, ...this.offsets.keys()])
    const targets = new Map()
    for (const el of elements) targets.set(el, this.targetFor(el, gust, now))

    let moving = false
    for (const [el, target] of targets) {
      const resting = target === REST
      if (resting && !this.offsets.has(el)) continue

      const o = this.offsets.get(el) || { x: 0, y: 0, rot: 0 }
      o.x += (target.x - o.x) * 0.08
      o.y += (target.y - o.y) * 0.08
      o.rot += (target.rot - o.rot) * 0.08

      const settled = Math.abs(o.x) < 0.05 && Math.abs(o.y) < 0.05 && Math.abs(o.rot) < 0.01
      if (resting && settled) {
        this.offsets.delete(el)
        clearDrift(el)
        continue
      }
      this.offsets.set(el, o)
      el.style.translate = `${o.x.toFixed(2)}px ${o.y.toFixed(2)}px`
      el.style.rotate = `${o.rot.toFixed(3)}deg`
      moving = true
    }
    if (moving || gust) this.wake()
  }

  // How far the gust wants this element moved right now.
  targetFor(el, gust, now) {
    if (!gust || !this.visible.has(el) || el.matches(":hover, :focus-within")) return REST

    const rect = el.getBoundingClientRect()
    const dx = Math.max(rect.left - gust.x, 0, gust.x - rect.right)
    const dy = Math.max(rect.top - gust.y, 0, gust.y - rect.bottom)
    const dist = Math.hypot(dx, dy)
    if (dist >= this.reachValue) return REST

    const t = (1 - smoothstep(0, this.reachValue, dist)) * gust.strength
    const flutter = 0.75 + 0.25 * Math.sin(now / 140 + rect.left * 0.05) // neighbours sway out of step
    const k = t * flutter
    return {
      x: gust.windX * this.driftValue * k,
      y: gust.windY * this.driftValue * k,
      rot: gust.windX * this.tiltValue * k
    }
  }

  settleAll() {
    cancelAnimationFrame(this.rafId)
    this.rafId = null
    for (const el of this.offsets.keys()) clearDrift(el)
    this.offsets.clear()
  }
}

const REST = Object.freeze({ x: 0, y: 0, rot: 0 })

function clearDrift(el) {
  el.style.translate = ""
  el.style.rotate = ""
}
