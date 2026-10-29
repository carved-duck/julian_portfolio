import { smoothstep } from "wind/math"

// The hover lens: inside the mouse's circle the seigaiha subdivides into smaller and smaller copies
// of itself. Level 0 is the page's own scales; each level after it is the same grid at half the
// size. Every point of a coarser grid is also a point of the finer one, so the small waves grow out
// of the big ones instead of sitting on top of them.

// Where each level hands over to the next, as a share of the lens radius, outermost first.
const CUTS = [0.75, 0.4, 0.14]
const FADE = 0.09 // half-width of each cross-fade, same units
// Line width for each finer level, one per cut: finer waves get finer lines.
const LINE_WIDTHS = [0.9, 0.75, 0.6]
const LEVELS = CUTS.length

const FOLLOW = 0.35    // share of the remaining gap to the mouse covered each frame
const OPEN_EASE = 0.12 // share of the remaining gap to fully open (or closed) covered each frame

export class Lens {
  constructor(x, y, reach) {
    this.x = x
    this.y = y
    this.reach = reach
    this.open = 0
  }

  get radius() {
    return this.reach * this.open
  }

  get closed() {
    return this.open < 0.01
  }

  // Glide toward the mouse and open, or close where it is once the mouse has gone.
  // Returns true while anything is still changing.
  step(mouse) {
    const goal = mouse ? 1 : 0
    if (mouse) {
      this.x += (mouse.x - this.x) * FOLLOW
      this.y += (mouse.y - this.y) * FOLLOW
    }
    this.open += (goal - this.open) * OPEN_EASE
    const following = mouse && Math.hypot(mouse.x - this.x, mouse.y - this.y) > 0.1
    return following || Math.abs(goal - this.open) > 0.005
  }

  // How much of a level shows at (x, y), 0 to 1. At any point the levels' weights add up to ~1.
  weight(level, x, y) {
    if (this.radius < 0.5) return level === 0 ? 1 : 0
    const u = Math.hypot(x - this.x, y - this.y) / this.radius
    const fromOutside = level === 0 ? 1 : 1 - smoothstep(CUTS[level - 1] - FADE, CUTS[level - 1] + FADE, u)
    const fromInside = level === LEVELS ? 1 : smoothstep(CUTS[level] - FADE, CUTS[level] + FADE, u)
    return fromOutside * fromInside
  }

  // Calls add(x, y, radius, weight, lineWidth) for each smaller scale the lens shows.
  forEachFineScale(baseRadius, add) {
    for (let level = 1; level <= LEVELS; level++) {
      const r = baseRadius / 2 ** level
      const lineWidth = LINE_WIDTHS[level - 1]
      const outer = this.radius * (CUTS[level - 1] + FADE) // this level is invisible beyond here
      const lastRow = Math.floor((this.y + outer) / r)
      for (let row = Math.ceil((this.y - outer) / r); row <= lastRow; row++) {
        const y = row * r
        const shift = row & 1 ? r : 0 // same half-scale offset per row as the page's grid
        const firstX = Math.ceil((this.x - outer - shift) / (2 * r)) * 2 * r + shift
        for (let x = firstX; x <= this.x + outer; x += 2 * r) {
          const w = this.weight(level, x, y)
          if (w > 0.02) add(x, y, r, w, lineWidth)
        }
      }
    }
  }
}
