import { Controller } from "@hotwired/stimulus"

// Seigaiha (青海波) waves drawn on a <canvas>: rows of half-circle "scales", each row offset by half a
// scale. Near the mouse the scales slide outward and turn a little, like leaves pushed aside, then
// drift back. A tap on a touch screen sends a ripple through them. Under reduced motion the pattern
// is drawn once and stays still. It only animates while something is moving.
//
// <canvas data-controller="seigaiha"></canvas>
export default class extends Controller {
  static values = {
    color: { type: String, default: "141, 11, 65" }, // "r, g, b"
    alpha: { type: Number, default: 0.07 },           // resting line strength
    radius: { type: Number, default: 15 },            // scale radius, px
    reach: { type: Number, default: 100 },            // how far the mouse is felt, px
    push: { type: Number, default: 12 },              // max slide, px
    turn: { type: Number, default: 0.55 }             // max turn, radians
  }

  connect() {
    this.ctx = this.element.getContext("2d")
    if (!this.ctx) return

    this.mouse = null
    this.ripples = []
    this.rafId = null
    this.reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches
    this.hoverMQ = window.matchMedia("(hover: hover) and (pointer: fine)")

    this.onResize = () => {
      clearTimeout(this.resizeTimer)
      this.resizeTimer = setTimeout(() => this.resize(), 50)
    }
    this.onPointerMove = (e) => {
      if (e.pointerType !== "mouse" || !this.hoverMQ.matches) return
      this.mouse = this.toLocal(e.clientX, e.clientY)
      this.wake()
    }
    this.onPointerLeave = () => { this.mouse = null; this.wake() }
    this.onPointerDown = (e) => {
      if (e.pointerType === "mouse") return
      const p = this.toLocal(e.clientX, e.clientY)
      if (p) { this.ripples.push({ ...p, start: performance.now() }); this.wake() }
    }

    this.resize()
    window.addEventListener("resize", this.onResize)
    if (this.reducedMotion) return

    window.addEventListener("pointermove", this.onPointerMove)
    document.documentElement.addEventListener("pointerleave", this.onPointerLeave)
    window.addEventListener("pointerdown", this.onPointerDown)
  }

  disconnect() {
    cancelAnimationFrame(this.rafId)
    clearTimeout(this.resizeTimer)
    window.removeEventListener("resize", this.onResize)
    window.removeEventListener("pointermove", this.onPointerMove)
    document.documentElement.removeEventListener("pointerleave", this.onPointerLeave)
    window.removeEventListener("pointerdown", this.onPointerDown)
  }

  // Lay out the scales for the current size and draw the resting pattern.
  resize() {
    const dpr = window.devicePixelRatio || 1
    const rect = this.element.getBoundingClientRect()
    this.width = rect.width
    this.height = rect.height
    this.element.width = Math.max(1, Math.round(rect.width * dpr))
    this.element.height = Math.max(1, Math.round(rect.height * dpr))
    this.ctx.setTransform(dpr, 0, 0, dpr, 0, 0)

    const r = this.radiusValue
    this.scales = []
    for (let row = 0, y = 0; y <= this.height + r; row++, y += r) {
      const shift = row % 2 ? r : 0
      for (let x = shift - 2 * r; x <= this.width + 2 * r; x += 2 * r) {
        this.scales.push({ x, y, dx: 0, dy: 0, rot: 0, glow: 0 })
      }
    }
    this.draw()
  }

  toLocal(clientX, clientY) {
    const rect = this.element.getBoundingClientRect()
    const x = clientX - rect.left
    const y = clientY - rect.top
    if (x < 0 || y < 0 || x > rect.width || y > rect.height) return null
    return { x, y }
  }

  wake() {
    if (this.rafId === null && !document.hidden) this.rafId = requestAnimationFrame(() => this.frame())
  }

  frame() {
    this.rafId = null
    const now = performance.now()
    this.ripples = this.ripples.filter((rp) => now - rp.start < 900)
    const moving = this.step(now)
    this.draw()
    if (moving || this.ripples.length) this.wake() // a resting mouse needs no frames; pointermove wakes it
  }

  // Move every scale a step toward where the mouse (and any ripple) wants it. Returns true while
  // anything is still in motion.
  step(now) {
    const reach = this.reachValue
    let moving = false

    for (const s of this.scales) {
      let tx = 0, ty = 0, trot = 0, tglow = 0

      if (this.mouse) {
        const vx = s.x - this.mouse.x
        const vy = s.y - this.mouse.y
        const dist = Math.hypot(vx, vy)
        if (dist < reach) {
          const t = 1 - smoothstep(0, reach, dist)
          const nx = dist > 0 ? vx / dist : 0
          const ny = dist > 0 ? vy / dist : 0
          tx += nx * this.pushValue * t
          ty += ny * this.pushValue * t
          trot += nx * this.turnValue * t // scales left of the mouse turn one way, right the other
          tglow = Math.max(tglow, t)
        }
      }

      for (const rp of this.ripples) {
        const age = (now - rp.start) / 900
        const vx = s.x - rp.x
        const vy = s.y - rp.y
        const dist = Math.hypot(vx, vy)
        const ring = Math.abs(dist - 320 * age)
        if (ring < 60 && dist > 0) {
          const t = (1 - ring / 60) * (1 - age) ** 2
          tx += (vx / dist) * this.pushValue * t
          ty += (vy / dist) * this.pushValue * t
          trot += (vx / dist) * this.turnValue * t
          tglow = Math.max(tglow, t)
        }
      }

      // Ease toward the target: quick to part, softer to settle back.
      const k = (tx || ty) ? 0.2 : 0.1
      s.dx += (tx - s.dx) * k
      s.dy += (ty - s.dy) * k
      s.rot += (trot - s.rot) * k
      s.glow += (tglow - s.glow) * k
      if (Math.abs(s.dx) > 0.05 || Math.abs(s.dy) > 0.05 || Math.abs(s.rot) > 0.002) moving = true
    }
    return moving
  }

  draw() {
    const { ctx } = this
    const r = this.radiusValue
    const inner = r * 0.5
    ctx.clearRect(0, 0, this.width, this.height)
    ctx.lineWidth = 1

    // Resting scales: one path, one stroke.
    ctx.beginPath()
    const active = []
    for (const s of this.scales) {
      if (s.glow > 0.01 || Math.abs(s.dx) > 0.05 || Math.abs(s.dy) > 0.05) { active.push(s); continue }
      ctx.moveTo(s.x - r, s.y)
      ctx.arc(s.x, s.y, r, Math.PI, 2 * Math.PI)
      ctx.moveTo(s.x - inner, s.y)
      ctx.arc(s.x, s.y, inner, Math.PI, 2 * Math.PI)
    }
    ctx.strokeStyle = `rgba(${this.colorValue}, ${this.alphaValue})`
    ctx.stroke()

    // Moving scales: each one shifted, turned, and a little stronger while it moves.
    for (const s of active) {
      ctx.save()
      ctx.translate(s.x + s.dx, s.y + s.dy)
      ctx.rotate(s.rot)
      ctx.beginPath()
      ctx.moveTo(-r, 0)
      ctx.arc(0, 0, r, Math.PI, 2 * Math.PI)
      ctx.moveTo(-inner, 0)
      ctx.arc(0, 0, inner, Math.PI, 2 * Math.PI)
      ctx.strokeStyle = `rgba(${this.colorValue}, ${(this.alphaValue + 0.16 * s.glow).toFixed(3)})`
      ctx.stroke()
      ctx.restore()
    }
  }
}

function smoothstep(edge0, edge1, x) {
  const t = Math.max(0, Math.min(1, (x - edge0) / (edge1 - edge0)))
  return t * t * (3 - 2 * t)
}
