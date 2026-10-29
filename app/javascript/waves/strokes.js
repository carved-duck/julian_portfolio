import { addScale } from "waves/scale"

// Groups scales into one path per look (colour, strength, width), so a frame is a few dozen strokes
// rather than one per moving scale (thousands on a wide screen while a billow passes). Strength is
// rounded to 1/200; anything fainter rounds to 0 and is skipped.
export class StrokeBatch {
  constructor() {
    this.looks = new Map()
  }

  addScale(color, alpha, width, x, y, radius, rot) {
    const rounded = Math.round(alpha * 200) / 200
    if (rounded <= 0) return
    const key = `${color} ${rounded} ${width}`
    let look = this.looks.get(key)
    if (!look) {
      look = { color, alpha: rounded, width, path: new Path2D() }
      this.looks.set(key, look)
    }
    addScale(look.path, x, y, radius, rot)
  }

  stroke(ctx) {
    for (const { color, alpha, width, path } of this.looks.values()) {
      ctx.lineWidth = width
      ctx.strokeStyle = `rgba(${color}, ${alpha})`
      ctx.stroke(path)
    }
  }
}
