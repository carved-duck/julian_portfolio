// One seigaiha scale: an outer and an inner half-circle, opening downward. Turning a half-circle
// about its centre only shifts its start and end angles, so no canvas transform is needed.
export function addScale(path, x, y, radius, rot) {
  for (const rad of [radius, radius * 0.5]) {
    path.moveTo(x + rad * Math.cos(Math.PI + rot), y + rad * Math.sin(Math.PI + rot))
    path.arc(x, y, rad, Math.PI + rot, 2 * Math.PI + rot)
  }
}
