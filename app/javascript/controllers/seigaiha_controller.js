import { Controller } from "@hotwired/stimulus"
import { createBillow } from "wind/billow"
import { clamp, random, smoothstep } from "wind/math"
import { Lens } from "waves/lens"
import { GLINT, GOLD, LIGHT, SHADOW, lightAt } from "waves/light"
import { REST, atRest, easeScale, newScale } from "waves/scale"
import { StrokeBatch } from "waves/strokes"

// Seigaiha (青海波) waves drawn on a <canvas>: rows of half-circle "scales", each row offset by half a
// scale. Around the mouse the pattern opens a circle filled with smaller and smaller copies of itself
// (waves/lens.js), and the big scales at its rim part a little. A click or tap sends a ripple
// through them. Every few seconds the wind lifts the pattern like cloth: a billow
// (wind/billow.js) rolls across the page and the scales rise and tilt as it passes, catching the
// light in gold and casting a shadow (waves/light.js). Its start is sent out as a
// "seigaiha:billow" event and its end as "seigaiha:billow-end", so wind_float_controller can float
// cards on it. Billows rest after a minute with no scroll, key or
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
    this.wind = { x: 1, y: 0 } // the last billow's direction; shadows keep it while the cloth settles
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
    this.wind = { x: billow.dirX, y: billow.dirY }
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
        this.scales.push(previous.get(`${x},${y}`) || newScale(x, y))
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
    const billowMs = this.billow ? now - this.billow.start : 0
    const target = { ...REST }

    for (const s of this.scales) {
      Object.assign(target, REST)
      if (this.lens) this.partAtRim(s, target)
      if (this.billow) this.liftWithBillow(s, target, billowMs)
      for (const rp of this.ripples) this.pushWithRipple(s, target, rp, now)

      // Quick to part, softer to settle back. Done once it has arrived, even if that is away from
      // rest (the lens rim holds scales parted while the mouse sits still).
      const k = (target.dx || target.dy) ? 0.2 : 0.1
      if (!easeScale(s, target, k)) moving = true
    }
    return moving
  }

  // Big scales around the lens rim part outward a little, so the circle reads as an opening.
  partAtRim(s, target) {
    const { lens } = this
    const vx = s.x - lens.x
    const vy = s.y - lens.y
    const dist = Math.hypot(vx, vy)
    const felt = lens.radius * 1.15
    if (dist >= felt || dist === 0) return
    const t = 1 - smoothstep(lens.radius * 0.5, felt, dist)
    const part = RIM_PUSH * t
    target.dx += (vx / dist) * this.pushValue * part
    target.dy += (vy / dist) * this.pushValue * part
    target.rot += (vx / dist) * this.turnValue * part // left of the lens turn one way, right the other
    target.glow = Math.max(target.glow, t)
  }

  // Lifted cloth: the scale rises (moves up the screen), is carried a little downwind, grows as if
  // nearer the eye, and tilts with the slope of the fold. Light comes from upwind, so the face ahead
  // of the crest darkens and the face behind it fades to let the gold show (waves/light.js).
  liftWithBillow(s, target, ms) {
    const { billow } = this
    const push = this.pushValue
    const { lift, slope } = billow.sample(s.x, s.y, ms)
    if (Math.abs(lift) <= 0.005 && Math.abs(slope) <= 0.02) return
    target.dx += billow.dirX * push * 0.35 * lift
    target.dy += billow.dirY * push * 0.35 * lift - push * 0.6 * lift
    target.rot += slope * this.turnValue * 0.6
    target.size += 0.16 * lift
    const shade = 0.5 * lift + 0.8 * (slope > 0 ? slope : 1.6 * slope)
    target.glow = target.glow > 0 ? Math.max(target.glow, shade) : shade
    const { sheen, glint } = lightAt(lift, slope, s.spark)
    target.lift = lift
    target.sheen = sheen
    target.glint = glint
  }

  pushWithRipple(s, target, rp, now) {
    const age = (now - rp.start) / 900
    const vx = s.x - rp.x
    const vy = s.y - rp.y
    const dist = Math.hypot(vx, vy)
    const ring = Math.abs(dist - 320 * age)
    if (ring >= 60 || dist === 0) return
    const t = (1 - ring / 60) * (1 - age) ** 2
    target.dx += (vx / dist) * this.pushValue * t
    target.dy += (vy / dist) * this.pushValue * t
    target.rot += (vx / dist) * this.turnValue * t
    target.glow = Math.max(target.glow, t)
  }

  // Three layers, bottom to top: shadows on the cloth, the burgundy lines, then gold and glints.
  draw() {
    const { ctx, lens } = this
    const r = this.radiusValue
    const rest = this.alphaValue
    ctx.clearRect(0, 0, this.width, this.height)
    const shadows = new StrokeBatch()
    const lines = new StrokeBatch()
    const light = new StrokeBatch()

    for (const s of this.scales) {
      const shown = lens ? lens.weight(0, s.x, s.y) : 1 // big scales fade out inside the lens
      if (shown < 0.02) continue
      if (shown === 1 && atRest(s)) {
        lines.addScale(this.colorValue, rest, 1, s.x, s.y, r, 0)
        continue
      }
      const x = s.x + s.dx
      const y = s.y + s.dy
      const radius = r * s.size
      const alpha = this.lineAlpha(s.glow)
      const width = alpha > rest ? 1.15 : 1 // darker lines are a touch thicker too
      lines.addScale(this.colorValue, alpha * shown, width, x, y, radius, s.rot)
      if (s.lift > 0.02) this.addShadow(shadows, s, x, y, radius, shown)
      if (s.sheen > 0.01) light.addScale(GOLD, rest * LIGHT.gold * s.sheen * shown, 1.15, x, y, radius, s.rot)
      if (s.glint > 0.02) {
        light.addScale(GLINT, rest * LIGHT.halo * s.glint * shown, 3, x, y, radius, s.rot)
        light.addScale(GLINT, rest * LIGHT.glint * s.glint * shown, 1.5, x, y, radius, s.rot)
      }
    }

    lens?.forEachFineScale(r, (x, y, radius, weight, lineWidth) => {
      lines.addScale(this.colorValue, rest * FINE_ALPHA * weight, lineWidth, x, y, radius, 0)
    })

    for (const batch of [shadows, lines, light]) batch.stroke(ctx)
  }

  // The raised scale's shadow falls below it and a little downwind, further the higher it is lifted.
  addShadow(batch, s, x, y, radius, shown) {
    const drop = this.pushValue * s.lift
    const alpha = this.alphaValue * LIGHT.shadow * s.lift * shown
    batch.addScale(SHADOW, alpha, 2.5, x + this.wind.x * drop * LIGHT.shadowRun,
      y + drop * LIGHT.shadowDrop, radius, s.rot)
  }

  // Positive glow darkens a line; negative glow (the lit face of a billow) fades it, in proportion
  // to the resting strength so the quieter inner pages fade as gently as Home, and never to nothing.
  lineAlpha(glow) {
    if (glow >= 0) return this.alphaValue + 0.16 * glow
    return this.alphaValue * Math.max(0.3, 1 + 0.55 * glow)
  }
}
