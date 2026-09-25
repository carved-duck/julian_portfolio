# Styling — SCSS layout, brand colors

ELI5: where the styles live and which colors are "ours". Checked 2026-09-25.

## Layout of `app/assets/stylesheets/`
`config/` (fonts, colors, Bootstrap variable overrides) → vendor imports → `components/` →
`pages/`. A new component partial also needs its `@import` in `components/_index.scss`.

## Brand colors
- The brand primary is **burgundy `#8D0B41`**, defined as the CSS variable `--burgundy` in
  `components/_depth.scss`, with `--gold`, `--sage` and cream as secondaries. Use the variables,
  not raw hex.
- **Bootstrap's `$primary` is still Bootstrap blue** (`config/_bootstrap_variables.scss`:
  `$primary: $blue`). So `.btn-primary`, `.text-primary` and friends render blue unless a rule
  overrides them. Switching `$primary` to burgundy is a redesign decision, not a quiet fix.
- A seasonal palette is defined in `_depth.scss` as CSS variables and the classes
  `.spring-theme`, `.summer-theme`, `.fall-theme`, `.winter-theme`. No view uses them today.

## Dark mode
There is none: no `prefers-color-scheme`, no theme switch. `.photo-info-dark` styles overlays on
dark photos, not an app theme.
