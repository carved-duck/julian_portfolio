import { random, clamp } from "wind/math"

// One gust of wind crossing the page, always left to right. It enters anywhere on the left edge,
// leaves anywhere on the right (at most MAX_ANGLE off level), bends along the way, and sometimes
// winds into a small swirl that keeps drifting right while it spins.
//
// createGust(width, height) returns a function of elapsed ms that gives the gust's point
// { x, y, dirX, dirY, windX, windY, strength }, or null once the gust has left the page.
// dir is where the point is heading this instant (it circles inside a swirl); wind is the gust's
// overall direction, which never points left.

const MAX_ANGLE = (40 * Math.PI) / 180
const SWIRL_CHANCE = 0.6
const SWIRL_ADVANCE = 0.06 // how far along the path the swirl drifts while it spins (0–1)

export function createGust(width, height) {
  const margin = 120 // start and end off screen so the gust never pops in
  const from = { x: -margin, y: random(0.1, 0.9) * height }
  const to = { x: width + margin, y: pickExitY(from.y, width + 2 * margin, height) }

  const length = Math.hypot(to.x - from.x, to.y - from.y)
  const along = { x: (to.x - from.x) / length, y: (to.y - from.y) / length }
  const across = { x: -along.y, y: along.x }

  // One gentle bend over the whole path, plus a smaller wobble. Sized from the shorter side so a
  // narrow phone screen doesn't turn the bend into a steep climb.
  const size = Math.min(width, height, 700)
  const bend = random(0.06, 0.16) * size * (Math.random() < 0.5 ? -1 : 1)
  const wobble = random(0.02, 0.05) * size
  const wobblePhase = random(0, Math.PI * 2)

  const travelMs = clamp((width / 420) * 1000, 2600, 5000)
  const swirl = Math.random() < SWIRL_CHANCE ? makeSwirl() : null
  // A swirl spends SWIRL_ADVANCE of the path while spinning, so less of it is left to travel.
  const totalMs = swirl ? travelMs * (1 - SWIRL_ADVANCE) + swirl.ms : travelMs

  // Progress u (0–1) along the path at elapsed ms; a swirl slows it to a crawl while it spins.
  function progressAt(ms) {
    if (!swirl) return ms / travelMs
    const beforeMs = travelMs * swirl.at
    if (ms < beforeMs) return ms / travelMs
    if (ms < beforeMs + swirl.ms) return swirl.at + SWIRL_ADVANCE * ((ms - beforeMs) / swirl.ms)
    return swirl.at + SWIRL_ADVANCE + (ms - beforeMs - swirl.ms) / travelMs
  }

  function positionAt(ms) {
    const u = Math.min(1, progressAt(ms))
    const side = bend * Math.sin(Math.PI * u) + wobble * Math.sin(3 * Math.PI * u + wobblePhase)
    let x = from.x + along.x * length * u + across.x * side
    let y = from.y + along.y * length * u + across.y * side

    if (swirl) {
      const s = (ms - travelMs * swirl.at) / swirl.ms
      if (s > 0 && s < 1) {
        // Starts heading right, then loops below (spin 1, clockwise) or above (-1) the path.
        const angle = swirl.turns * 2 * Math.PI * s
        const radius = swirl.radius * Math.sin(Math.PI * s) // grows, then shrinks back to the path
        x += radius * Math.sin(angle)
        y += radius * (1 - Math.cos(angle)) * swirl.spin
      }
    }
    return { x, y }
  }

  return (ms) => {
    if (ms >= totalMs) return null
    const here = positionAt(ms)
    const ahead = positionAt(ms + 16)
    const speed = Math.hypot(ahead.x - here.x, ahead.y - here.y) || 1
    const strength = Math.min(1, ms / 500, (totalMs - ms) / 500) // ease in and out
    return {
      x: here.x,
      y: here.y,
      dirX: (ahead.x - here.x) / speed,
      dirY: (ahead.y - here.y) / speed,
      windX: along.x,
      windY: along.y,
      strength
    }
  }
}

function makeSwirl() {
  return {
    at: random(0.3, 0.6),                // where along the path it starts
    ms: random(1400, 2200),
    turns: random(1.2, 2.2),
    radius: random(35, 80),
    spin: Math.random() < 0.5 ? 1 : -1   // clockwise or counter-clockwise
  }
}

// An exit point on the right edge, no steeper than MAX_ANGLE from the entry point.
function pickExitY(entryY, run, height) {
  const maxRise = Math.tan(MAX_ANGLE) * run
  const low = Math.max(0.05 * height, entryY - maxRise)
  const high = Math.min(0.95 * height, entryY + maxRise)
  return random(low, high)
}
