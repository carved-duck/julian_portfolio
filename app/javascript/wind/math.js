// Small number helpers shared by the wave background and the wind.

export function random(min, max) {
  return min + Math.random() * (max - min)
}

export function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value))
}

// 0 at edge0, 1 at edge1, with a soft start and finish.
export function smoothstep(edge0, edge1, x) {
  const t = clamp((x - edge0) / (edge1 - edge0), 0, 1)
  return t * t * (3 - 2 * t)
}
