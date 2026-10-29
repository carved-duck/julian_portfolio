import { smoothstep } from "wind/math"

// How light plays on the cloth a billow lifts. Light comes from upwind and above: the face ahead of
// the crest darkens (glow, in the controller), the face behind it catches the light and turns gold
// (gold thread on burgundy, as on a kimono), the crest glints, and the raised fold casts a soft
// shadow downwind onto the cloth below. The page is near-white, so a glint can't be lighter than
// it; it reads as shine by being a brighter, thicker gold with a soft halo.

// Fixed, not taken from the controller's `color` value: a page that changes that colour would need
// these changed to match.
export const GOLD = "190, 136, 28"
export const GLINT = "224, 162, 32"
export const SHADOW = "70, 12, 35"

// Strengths are multiples of the page's resting line strength, so the quieter inner pages stay quiet.
// Shadow offsets are shares of the controller's `push`.
export const LIGHT = {
  gold: 5,         // lit-face line at full sheen
  glint: 7,        // crest line at full glint
  halo: 2,         // the soft wide stroke under a glint
  shadow: 1.6,     // shadow line at a full crest
  shadowDrop: 0.9, // offsets are shares of `push`, at a full crest: how far below the raised scale
  shadowRun: 0.4   // its shadow falls, and how far downwind
}

// sheen: the lit face behind the crest (and the backs of the flutter ripples). glint: the crest,
// where the cloth is high and level; the few scales with a high spark flash brightest, like silk.
export function lightAt(lift, slope, spark) {
  const sheen = smoothstep(0.05, 0.45, -slope) * smoothstep(0, 0.15, lift)
  const crest = smoothstep(0.3, 0.65, lift) * (1 - smoothstep(0.15, 0.6, Math.abs(slope)))
  const glint = crest * (spark > 0.85 ? 1 : 0.55)
  return { sheen, glint }
}
