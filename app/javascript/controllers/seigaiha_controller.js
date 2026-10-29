import { Controller } from "@hotwired/stimulus"
import { createBillow } from "wind/billow"
import { clamp, random, smoothstep } from "wind/math"
import { Lens } from "waves/lens"
import { addScale } from "waves/scale"

// Seigaiha (青海波) waves drawn on a <canvas>: rows of half-circle "scales", each row offset by half a
// scale. Around the mouse the pattern opens a circle filled with smaller and smaller copies of itself
// (waves/lens.js), and the big scales at its rim part a little. A click or tap sends a ripple
// through them. Every few seconds the wind lifts the pattern like cloth: a billow
// (wind/billow.js) rolls across the page and the scales rise, tilt and darken as it passes. Its
// start is sent out as a "seigaiha:billow" event and its end as "seigaiha:billow-end", so
// wind_float_controller can float cards on it. Billows rest after a minute with no scroll, key or
// pointer input, so a page left open costs no battery. Under reduced motion the pattern is drawn
// once and stays still. It only animates while something moves.
//
// <canvas data-controller="seigaiha"></canvas>
const IDLE_MS = 60000
const RIM_PUSH = 0.4   // share of `push` the lens rim parts the big scales by
const FINE_ALPHA = 1.6 // the smaller waves' line strength, as a multiple of the resting strength

export default class extends Controller {
  static values = {
    color: { type: String, default: "141, 11, 65" }, // "r, g, b"
    alpha: { type: Number, default: 0.07 },           // resting line strength
    radius: { type: Number, default: 15 },            // scale radius, px
    reach: { type: Number, default: 55 },            // radius of the circle the mouse opens, px
    push: { type: Number, default: 12 },              // max slide, px
    turn: { type: Number, default: 0.55 },            // max turn, radians
    billowEvery: { type: Array, default: [4000, 8000] } // ms between billows: [min, max]
  }

  connect() {
    this.ctx = this.element.getContext("2d")
    if (!this.ctx) return

    this.mouse = null
    this.lens = null
    this.ripples = []
    this.billow = null
    this.rafId = null
    this.lastInputAt = performance.now()
    this.reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches
    this.hoverMQ = window.matchMedia("(hover: hover) and (pointer: fine)")

    this.onResize = () => {
      clearTimeout(this.resizeTimer)
      this.resizeTimer = setTimeout(() => this.resize(), 50)
    }
    this.onInput = () => { this.lastInputAt = performance.now() }
    this.onPointerMove = (e) => {
      this.onInput()
      if (e.pointerType !== "mouse" || !this.hoverMQ.matches) return
      this.mouse = this.toLocal(e.clientX, e.clientY)
      this.wake()
    }
    this.onPointerLeave = () => { this.mouse = null; this.wake() }
    this.onPointerDown = (e) => {
      this.onInput()
      const p = this.toLocal(e.clientX, e.clientY)
      if (p) { this.ripples.push({ ...p, start: performance.now() }); this.wake() }
    }
    // Chrome runs no frames in a hidden tab; pick a half-finished billow back up on return.
    this.onVisibility = () => this.wake()

    this.resize()
    window.addEventListener("resize", this.onResize)
    if (this.reducedMotion) return

    window.addEventListener("pointermove", this.onPointerMove)
    document.documentElement.addEventListener("pointerleave", this.onPointerLeave)
    window.addEventListener("pointerdown", this.onPointerDown)
    document.addEventListener("visibilitychange", this.onVisibility)
    window.addEventListener("scroll", this.onInput, { passive: true })
    window.addEventListener("keydown", this.onInput)
    this.scheduleBillow(random(1500, 3000)) // the first one comes soon, so a visitor sees it
  }

  disconnect() {
    cancelAnimationFrame(this.rafId)
    clearTimeout(this.resizeTimer)
    clearTimeout(this.billowTimer)
    window.removeEventListener("resize", this.onResize)
    window.removeEventListener("pointermove", this.onPointerMove)
    document.documentElement.removeEventListener("pointerleave", this.onPointerLeave)
    window.removeEventListener("pointerdown", this.onPointerDown)
    document.removeEventListener("visibilitychange", this.onVisibility)
    window.removeEventListener("scroll", this.onInput)
    window.removeEventListener("keydown", this.onInput)
  }

  scheduleBillow(delay) {
    clearTimeout(this.billowTimer)
    this.billowTimer = setTimeout(() => {
      // Wait while nobody can see the page, is using it, or a pop-up such as the photo viewer covers it.
      const covered = document.body.classList.contains("modal-open")
      const idle = performance.now() - this.lastInputAt > IDLE_MS
      if (document.hidden || covered || idle) return this.scheduleBillow(1000)
      this.startBillow()
    }, delay)
  }

  startBillow() {
    const billow = createBillow(this.width, this.height)
    const start = performance.now()
    this.billow = { ...billow, width: this.width, start }
    // Cards sample the same cloth, in viewport coordinates and page time. A point off screen (a tall
    // card's centre) samples the nearest on-screen spot, so it never floats before the fold arrives
    // or after it has gone.
    const { width, height } = this
    const sample = (clientX, clientY, now) =>
      billow.sample(clamp(clientX - this.left, 0, width), clamp(clientY - this.top, 0, height), now - start)
    this.dispatch("billow", { detail: { sample, dirX: billow.dirX, dirY: billow.dirY } })
    this.wake()
  }

  // Once the billow has rolled off the page, book the next one.
  endBillowIfDone(now) {
    if (this.billow && now - this.billow.start >= this.billow.ms) this.endBillow()
  }

  endBillow() {
    this.billow = null
    this.dispatch("billow-end")
    this.scheduleBillow(random(...this.billowEveryValue))
  }

  // Lay out the scales for the current size and draw the resting pattern.
  resize() {
    const dpr = window.devicePixelRatio || 1
    const rect = this.element.getBoundingClientRect()
    this.left = rect.left // cached: reading it per frame would force a layout after the card float writes
    this.top = rect.top
    this.width = rect.width
    this.height = rect.height
    this.element.width = Math.max(1, Math.round(rect.width * dpr))
    this.element.height = Math.max(1, Math.round(rect.height * dpr))
    this.ctx.setTransform(dpr, 0, 0, dpr, 0, 0)
    // A billow is shaped for the width it started at; after a rotation or window resize, let the
    // scales settle and start a fresh one later. (A phone toolbar only changes the height.)
    if (this.billow && this.billow.width !== this.width) this.endBillow()

    // Keep each scale's motion across the resize: a phone's toolbar hiding mid-scroll resizes the
    // page, and starting every scale from rest would flatten a passing billow in one frame.
    const previous = new Map((this.scales || []).map((s) => [`${s.x},${s.y}`, s]))
    const r = this.radiusValue
    this.scales = []
    for (let row = 0, y = 0; y <= this.height + r; row++, y += r) {
      const shift = row % 2 ? r : 0
      for (let x = shift - 2 * r; x <= this.width + 2 * r; x += 2 * r) {
        this.scales.push(previous.get(`${x},${y}`) || { x, y, dx: 0, dy: 0, rot: 0, size: 1, glow: 0 })
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
    this.endBillowIfDone(now)
    const moving = this.step(now)
    this.draw()
    // A resting mouse needs no frames; pointermove wakes it.
    if (moving || this.ripples.length || this.billow) this.wake()
  }

  // The lens follows the mouse and opens; once the mouse has gone it closes where it is.
  stepLens() {
    if (this.mouse && !this.lens) this.lens = new Lens(this.mouse.x, this.mouse.y, this.reachValue)
    if (!this.lens) return false
    const changing = this.lens.step(this.mouse)
    if (!this.mouse && this.lens.closed) this.lens = null
    return changing
  }

  // Move every scale a step toward where the lens, the billow and any ripple want it. Returns true
  // while anything is still in motion.
  step(now) {
    let moving = this.stepLens()
    const push = this.pushValue
    const lens = this.lens
    const billow = this.billow
    const billowMs = billow ? now - billow.start : 0

    for (const s of this.scales) {
      let tx = 0, ty = 0, trot = 0, tsize = 1, tglow = 0

      // Big scales around the rim part outward a little, so the circle reads as an opening.
      if (lens) {
        const vx = s.x - lens.x
        const vy = s.y - lens.y
        const dist = Math.hypot(vx, vy)
        const felt = lens.radius * 1.15
        if (dist < felt && dist > 0) {
          const t = 1 - smoothstep(lens.radius * 0.5, felt, dist)
          tx += (vx / dist) * push * RIM_PUSH * t
          ty += (vy / dist) * push * RIM_PUSH * t
          trot += (vx / dist) * this.turnValue * RIM_PUSH * t // left of the lens turn one way, right the other
          tglow = Math.max(tglow, t)
        }
      }

      // Lifted cloth: the scale rises (moves up the screen), is carried a little downwind, grows as
      // if nearer the eye, and tilts with the slope of the fold. Light comes from upwind, so the
      // face ahead of the crest darkens and the face behind it catches the light and fades.
      if (billow) {
        const { lift, slope } = billow.sample(s.x, s.y, billowMs)
        if (Math.abs(lift) > 0.005 || Math.abs(slope) > 0.02) {
          tx += billow.dirX * push * 0.35 * lift
          ty += billow.dirY * push * 0.35 * lift - push * 0.6 * lift
          trot += slope * this.turnValue * 0.6
          tsize += 0.16 * lift
          const shade = 0.5 * lift + 0.8 * (slope > 0 ? slope : 1.6 * slope)
          tglow = tglow > 0 ? Math.max(tglow, shade) : shade
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
          tx += (vx / dist) * push * t
          ty += (vy / dist) * push * t
          trot += (vx / dist) * this.turnValue * t
          tglow = Math.max(tglow, t)
        }
      }

      // Ease toward the target: quick to part, softer to settle back. Done once it has arrived, even
      // if that is away from rest (the lens rim holds scales parted while the mouse sits still).
      const k = (tx || ty) ? 0.2 : 0.1
      s.dx += (tx - s.dx) * k
      s.dy += (ty - s.dy) * k
      s.rot += (trot - s.rot) * k
      s.size += (tsize - s.size) * k
      s.glow += (tglow - s.glow) * k
      if (!near(s, tx, ty, trot, tsize, tglow)) moving = true
    }
    return moving
  }

  // Every scale goes into one path per line strength and width, so a frame is a handful of strokes
  // rather than one per moving scale (thousands on a wide screen while a billow passes).
  draw() {
    const { ctx, lens } = this
    const r = this.radiusValue
    ctx.clearRect(0, 0, this.width, this.height)

    const paths = new Map() // "alpha width" -> { alpha, width, path }
    const pathFor = (rawAlpha, width) => {
      const alpha = Math.round(rawAlpha * 200) / 200
      const key = `${alpha} ${width}`
      if (!paths.has(key)) paths.set(key, { alpha, width, path: new Path2D() })
      return paths.get(key).path
    }

    for (const s of this.scales) {
      const shown = lens ? lens.weight(0, s.x, s.y) : 1 // big scales fade out inside the lens
      if (shown < 0.02) continue
      if (shown === 1 && atRest(s)) {
        addScale(pathFor(this.alphaValue, 1), s.x, s.y, r, 0)
        continue
      }
      const alpha = this.lineAlpha(s.glow)
      const width = alpha > this.alphaValue ? 1.15 : 1 // darker lines are a touch thicker too
      addScale(pathFor(alpha * shown, width), s.x + s.dx, s.y + s.dy, r * s.size, s.rot)
    }

    lens?.forEachFineScale(r, (x, y, radius, weight, lineWidth) => {
      const alpha = this.alphaValue * FINE_ALPHA * weight
      if (alpha >= 0.0025) addScale(pathFor(alpha, lineWidth), x, y, radius, 0) // fainter rounds to 0
    })

    for (const { alpha, width, path } of paths.values()) {
      ctx.lineWidth = width
      ctx.strokeStyle = `rgba(${this.colorValue}, ${alpha})`
      ctx.stroke(path)
    }
  }

  // Positive glow darkens a line; negative glow (the lit face of a billow) fades it, in proportion
  // to the resting strength so the quieter inner pages fade as gently as Home, and never to nothing.
  lineAlpha(glow) {
    if (glow >= 0) return this.alphaValue + 0.16 * glow
    return this.alphaValue * Math.max(0.3, 1 + 0.55 * glow)
  }
}

// Close enough to its resting place and strength to draw as resting, and to stop animating.
function atRest(s) {
  return near(s, 0, 0, 0, 1, 0)
}

// Close enough to the given offset, turn, size and glow that another step would not show.
function near(s, dx, dy, rot, size, glow) {
  return Math.abs(s.dx - dx) <= 0.05 && Math.abs(s.dy - dy) <= 0.05 && Math.abs(s.rot - rot) <= 0.002 &&
    Math.abs(s.size - size) <= 0.002 && Math.abs(s.glow - glow) <= 0.01
}
