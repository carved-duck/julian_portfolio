# Styling — SCSS layout, brand colors

ELI5: where the styles live and which colors are "ours". Checked 2026-09-25.

## Layout of `app/assets/stylesheets/`
`config/` (fonts, colors, Bootstrap variable overrides) → vendor imports → `components/` →
`pages/`. A new component partial also needs its `@import` in `components/_index.scss`.

## Brand colors
- The brand primary is **burgundy `#8D0B41`**, in two places that must match: the Sass variable
  `$burgundy` (`config/_colors.scss`) and the CSS variable `--burgundy` (`components/_depth.scss`).
  `--gold`, `--sage` and `--cream` are the secondaries. In component SCSS use the CSS variables,
  not raw hex.
- **Bootstrap's `$primary` is burgundy** (`$primary: $burgundy`, since 2026-09-25). Links, focus
  rings, `.text-primary`, `.bg-primary`, form checks and active states all follow it.
  `.btn-primary` / `.btn-outline-primary` are also restyled by hand in `components/_button.scss`.
- **`rgba(var(--burgundy), 0.3)` is invalid CSS**: the variable holds a hex code, and `rgba()` needs
  three numbers, so the browser drops the whole line (11 of these in `_button.scss` hid the button
  focus ring until 2026-09-25). For a see-through brand color, write the numbers: burgundy
  `141, 11, 65` · gold `211, 157, 85` · sage `214, 207, 180` · cream `255, 248, 230`.
- A seasonal palette is defined in `_depth.scss` as CSS variables and the classes
  `.spring-theme`, `.summer-theme`, `.fall-theme`, `.winter-theme`. No view uses them today.

## Dark mode
There is none: no `prefers-color-scheme`, no theme switch. `.photo-info-dark` styles overlays on
dark photos, not an app theme.
