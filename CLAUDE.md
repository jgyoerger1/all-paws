# All Paws Pet Care & Sitting website

One-page static site for Emily and Baylie's pet sitting business (house sitting, drop-ins, dog walking,
boarding, day care, litter and yard clean-up) in Hudson, Ohio. Built 2026-09-30 by Jordan from the business's
Facebook, Instagram and Rover presence.

- Live: https://jordanyoerger.com/all-paws/ (GitHub Pages from `main` / `docs`). The github.io project URL
  301s there because Jordan's user site owns the custom domain jordanyoerger.com.
- Repo: github.com/jgyoerger1/all-paws (PUBLIC: keep this file technical).
- Spelling is "Baylie" (confirmed by Jordan; some Rover reviews say "Bailey").

## Layout

```
src/head.html     title, meta, canonical + og URLs, Google Fonts link, LocalBusiness JSON-LD
src/body.html     the whole page (tokens below)
src/site.css      design tokens (light + dark), layout;  src/site.js  mobile menu, hero photo-stack shuffle
src/icons/*.svg   Phosphor icons (MIT), inlined via {{icon:name}}
source/raw/       original FB/IG photos (+ source/urls.txt listing where each came from)
build.ps1         resizes photos, expands tokens, writes docs/ and artifact/
docs/             BUILD OUTPUT = the live site (index.html, site.css, site.js, img/, .nojekyll)
artifact/         single-file preview copy with inline CSS/JS (gitignored, regenerated every build)
```

Tokens in head/body: `{{rover}}`, `{{promo}}` (Rover links set at the top of build.ps1), `{{year}}`, `{{stars}}`,
`{{icon:name}}`, `{{img:name|alt text|extra attrs or eager}}` (emits width/height + lazy loading). Unknown tokens,
missing icons or missing photos throw.

## Build, preview, publish (verified against the scripts)

Windows PowerShell 5.1 (`powershell.exe`; uses System.Drawing) and git. No Node needed.

```
powershell -NoProfile -ExecutionPolicy Bypass -File build.ps1 [-SkipImages]
powershell -NoProfile -ExecutionPolicy Bypass -File serve.ps1 -Port 8770     # http://localhost:8770/
```
- `serve.ps1` defaults to port 8765 if `-Port` is omitted; README and past sessions use 8770.
- `Publish.cmd` = build + `git add -A` + commit + push; the live site updates in a minute or two.
- New photo: drop it in `source/raw/`, add `'friendly-name' = @('raw-file', 1100)` to `$photos` in build.ps1,
  use `{{img:friendly-name|alt}}` in body.html, rebuild.

## Design decisions

- Brand periwinkle `#756AE4` from their logo, darker `#5B4FD4` for buttons/theme-color (contrast); logo orange
  `#E89B42` as ornament only. Fonts Bricolage Grotesque + Figtree (Google Fonts). Light and dark themes.
- Split hero with a self-shuffling photo stack; Rover stats strip; six-cell services bento; about section built
  around the duo's photo; four-step booking line; scrolling review row; gallery; FAQ; closing CTA.
- Every "Book" CTA goes to their Rover profile (Jordan's choice): no phone, email or contact form on the site.
  The FAQ mentions the Rover new-customer referral credit (`{{promo}}`).
- No prices on the site; rates live on Rover.
- Stats (5.0 rating, 24 reviews, 11 repeat clients, 12 years) and review excerpts are from Rover as of
  2026-09-30, trimmed, attributed first name + last initial + service. Update `src/body.html` when they change.
- build.ps1 refuses en/em dashes anywhere in head/body (house style: no dashes in visible copy).
- Animations respect `prefers-reduced-motion`; no horizontal scroll at phone width.

## Gotchas

- `.ps1` files must stay ASCII (PowerShell 5.1 reads BOM-less scripts as ANSI). `.gitattributes` forces CRLF for
  `.cmd`/`.ps1` and binary for images.
- Canonical/og URLs in `src/head.html` are absolute to jordanyoerger.com/all-paws/. If they get their own domain:
  add `docs/CNAME`, update canonical/og/JSON-LD URLs in head.html, set DNS at their registrar.
- The claude.ai artifact preview (single-file copy in `artifact/`) was a one-off share for review; the live site
  is the source of truth.

## New machine

No hard-coded machine paths in build.ps1, serve.ps1 or Publish.cmd (all relative to `$PSScriptRoot` /
`%~dp0`). Set this repo's git identity to Jordan's GitHub noreply address before the next commit.

## Not in the repo / external

- Their Rover, Facebook and Instagram profiles (links are in build.ps1 and head.html). GitHub Pages hosting via
  Jordan's GitHub account and the jordanyoerger.com user site.

## Open items

- Service-area towns beyond "Hudson and surrounding areas" unknown.
- Optional: their own domain; add the site link to their Instagram bio, Facebook page and Rover profile.
- Refresh Rover stats and review excerpts periodically.
