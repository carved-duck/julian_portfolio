// One seigaiha scale: where it is drawn and how it eases toward where the lens, wind and ripples want it.

// Offset (px), turn (radians), size, and the light on it: glow (+ darker, - fainter burgundy), lift
// (how high the billow holds it), sheen (gold on the lit face) and glint (the crest catching the light).
export const REST = Object.freeze({ dx: 0, dy: 0, rot: 0, size: 1, glow: 0, lift: 0, sheen: 0, glint: 0 })

// How close each value must be to its target before another step would not show.
const TOLERANCE = { dx: 0.05, dy: 0.05, rot: 0.002, size: 0.002, glow: 0.01, lift: 0.01, sheen: 0.01, glint: 0.01 }

// spark (fixed per scale) picks the few scales that flash brightest as the crest passes.
export function newScale(x, y) {
  return { x, y, ...REST, spark: Math.random() }
}

// Move a step toward the target; true once there is nothing left to show.
export function easeScale(s, target, k) {
  for (const key in TOLERANCE) s[key] += (target[key] - s[key]) * k
  return near(s, target)
}

export function atRest(s) {
  return near(s, REST)
}

function near(s, target) {
  for (const key in TOLERANCE) {
    if (Math.abs(s[key] - target[key]) > TOLERANCE[key]) return false
  }
  return true
}

// An outer and an inner half-circle, opening downward. Turning a half-circle about its centre only
// shifts its start and end angles, so no canvas transform is needed.
export function addScale(path, x, y, radius, rot) {
  for (const rad of [radius, radius * 0.5]) {
    path.moveTo(x + rad * Math.cos(Math.PI + rot), y + rad * Math.sin(Math.PI + rot))
    path.arc(x, y, rad, Math.PI + rot, 2 * Math.PI + rot)
  }
}
