import { clamp, random, smoothstep } from "wind/math"

// One billow: wind lifting a fold of loose cloth that rolls across the page, like an open kimono
// catching a breeze. The fold is not a straight, even wave. Its crest is curved, one end leads,
// its height swells and dips along its length and shifts as it goes, the cloth behind it flutters
// as it settles, and sometimes a smaller second fold follows.
//
// createBillow(width, height) returns { ms, dirX, dirY, sample(x, y, ms) }. sample gives the cloth
// at a point and time: lift (0 flat, about 1 at a full crest) and slope (about -1.4 to 1.4: positive
// on the face ahead of the crest, which falls away downwind; negative behind it). x, y and ms are
// relative to the screen's top-left and the billow's start. The fold starts and ends off screen.

const MAX_ANGLE = (25 * Math.PI) / 180 // the wind blows left to right, at most this far off level
const SECOND_FOLD_CHANCE = 0.55
const SLOPE_STEP = 3 // px, for measuring slope

// Sizes in px for a 1440px-wide screen; smaller screens get a proportionally narrower fold, so a
// phone sees a fold pass rather than the whole page lifting at once.
const FOLD = {
  rise: 90,         // the cloth rises over this distance in front of the crest
  settle: 170,      // and sinks back over this one behind it (cloth settles slowly)
  flutterWave: 75,  // between ripples in the settling cloth
  flutterTail: 210, // for the ripples to die out
  sway: [25, 60],   // how far the crest line wanders as it travels
  gap: [210, 330]   // from the first fold to the second
}
const FLUTTER = { height: 0.22, speed: 0.011 } // ripple height (share of the crest), phase per ms

export function createBillow(width, height) {
  const scale = clamp(width / 1440, 0.45, 1.15)
  const angle = random(-MAX_ANGLE, MAX_ANGLE)
  const dir = { x: Math.cos(angle), y: Math.sin(angle) }

  // u runs downwind, v across the wind. Find the screen's extent in both.
  const corners = [[0, 0], [width, 0], [0, height], [width, height]]
  const us = corners.map(([x, y]) => x * dir.x + y * dir.y)
  const vs = corners.map(([x, y]) => y * dir.x - x * dir.y)
  const vMid = (Math.min(...vs) + Math.max(...vs)) / 2
  const vHalf = (Math.max(...vs) - Math.min(...vs)) / 2
  const span = Math.min(vHalf * 2, 900) // so a huge screen doesn't get a huge slant

  const fold = makeFoldProfile(scale)
  const front = makeFront(span, scale)
  const fullness = makeFullness()
  const second = Math.random() < SECOND_FOLD_CHANCE
    ? { gap: random(...FOLD.gap) * scale, height: random(0.4, 0.6) }
    : null

  // The crest line moves downwind at a steady speed, from just before the screen to just past it
  // (settling cloth and second fold included).
  const speed = random(0.85, 1.15) * clamp(width / 4000, 0.22, 0.38) // px per ms
  const ahead = fold.ahead
  const behind = fold.behind + (second ? second.gap : 0)
  const startU = Math.min(...us) - ahead - front.maxOffset
  const endU = Math.max(...us) + front.maxOffset + behind
  const totalMs = (endU - startU) / speed

  // Both folds by distance from the first crest, eased to exactly 0 at the far end, so nothing
  // snaps flat where sample() stops looking.
  function folds(s, ms) {
    let lift = fold.at(s, ms)
    if (second) lift += second.height * fold.at(s + second.gap, ms)
    return lift * smoothstep(-behind, -0.8 * behind, s)
  }

  function sample(x, y, ms) {
    const u = x * dir.x + y * dir.y
    // -1 … 1 across the screen. Clamped so a point off screen (a tall card's centre) follows the
    // nearest edge instead of an extrapolated crest.
    const n = clamp((y * dir.x - x * dir.y - vMid) / vHalf, -1, 1)
    const crest = startU + speed * ms + front.offset(n, ms)
    const s = u - crest // > 0 ahead of the crest, < 0 behind it
    if (s > ahead || s < -behind) return FLAT

    const swell = 0.75 + 0.25 * Math.sin(Math.PI * clamp(ms / totalMs, 0, 1)) // fullest mid-screen
    const height = fullness(n, ms) * swell
    const lift = folds(s, ms) * height
    const slope = ((folds(s - SLOPE_STEP, ms) - folds(s + SLOPE_STEP, ms)) / (2 * SLOPE_STEP)) * fold.rise * height
    return { lift, slope }
  }

  return { ms: totalMs, dirX: dir.x, dirY: dir.y, sample }
}

const FLAT = Object.freeze({ lift: 0, slope: 0 })

// The cloth's height across one fold, by distance s from its crest: a quick rise in front, a slow
// settle behind, and a flutter in the settling cloth that trails the crest. ahead and behind are
// where it has all but faded out.
function makeFoldProfile(scale) {
  const rise = FOLD.rise * scale
  const settle = FOLD.settle * scale
  const wave = FOLD.flutterWave * scale
  const tail = FOLD.flutterTail * scale
  const at = (s, ms) => {
    if (s >= 0) return Math.exp(-((s / rise) ** 2))
    const settled = Math.exp(-((s / settle) ** 2))
    const ripple = Math.sin((2 * Math.PI * s) / wave + FLUTTER.speed * ms)
    const fade = Math.exp(s / tail) * (1 - Math.exp(-((s / (0.35 * settle)) ** 2))) // zero at the crest
    return settled + FLUTTER.height * ripple * fade
  }
  return { rise, at, ahead: 3 * rise, behind: Math.max(2 * settle, 2.5 * tail) }
}

// How far ahead (+) or behind (-) of the average crest each part of the fold is: one end leads,
// the middle bows, and a slow sway keeps the line changing shape as it travels.
function makeFront(span, scale) {
  const lead = random(0.1, 0.3) * span * (Math.random() < 0.5 ? -1 : 1)
  const bow = random(-0.12, 0.12) * span
  const sway = random(...FOLD.sway) * scale
  const a = { k: random(1.5, 2.5), w: random(0.0008, 0.0016), p: random(0, 2 * Math.PI) }
  const b = { k: random(3.5, 5), w: random(0.0012, 0.002), p: random(0, 2 * Math.PI) }
  return {
    maxOffset: Math.abs(lead) + Math.abs(bow) + sway,
    offset: (n, ms) => lead * n + bow * n * n +
      sway * (0.6 * Math.sin(a.k * Math.PI * n + a.w * ms + a.p) + 0.4 * Math.sin(b.k * Math.PI * n - b.w * ms + b.p))
  }
}

// How full the fold is along its length (0.3 … 1): some stretches billow high, some barely lift,
// and the full stretches wander along the fold as it travels.
function makeFullness() {
  const a = { k: random(1.2, 2.2), w: random(0.0006, 0.0012), p: random(0, 2 * Math.PI) }
  const b = { k: random(3, 5), p: random(0, 2 * Math.PI) }
  return (n, ms) => {
    const wander = 0.5 + 0.5 * Math.sin(a.k * Math.PI * n + a.w * ms + a.p)
    const texture = 0.65 + 0.35 * Math.sin(b.k * Math.PI * n + b.p)
    return 0.3 + 0.7 * wander * texture
  }
}
