# All Paws Pet Care & Sitting website

Static one-page site for Emily and Baylie's pet sitting business in Hudson, Ohio.
No installs needed; everything runs on Windows PowerShell.

## Folders
- `source\raw\` original photos pulled from their Facebook and Instagram (urls.txt lists where each came from)
- `src\` the page: `head.html`, `body.html`, `site.css`, `site.js`, `icons\` (Phosphor, MIT)
- `docs\` the built website (ready for GitHub Pages: publish from `main` / `docs`)
- `artifact\` the claude.ai preview copy (CSS and JS inlined)

## Rebuild
```
powershell -NoProfile -ExecutionPolicy Bypass -File build.ps1
```
Add `-SkipImages` when only text or styles changed.

## Preview locally
```
powershell -NoProfile -ExecutionPolicy Bypass -File serve.ps1 -Port 8770
```
then open http://localhost:8770/

## Swapping photos
1. Drop the new photo in `source\raw\` (for example `new-pup.jpg`).
2. Add a line to the `$photos` list in `build.ps1`: `'new-pup' = @('new-pup', 1100)`.
3. Use it in `src\body.html` as `{{img:new-pup|Describe the photo for screen readers}}`.
4. Rebuild.

## Links used
- Book on Rover: https://www.rover.com/sit/emilyl32569
- $20 referral credit: https://www.rover.com/promos/emilyl32569/
- Instagram: https://www.instagram.com/allpawspetcarenv/
- Facebook: https://www.facebook.com/allpawspetcarenv

Stats on the page (5.0 rating, 24 reviews, 11 repeat clients, 12 years) and all review quotes
come from the Rover profile as of 2026-09-30. Update `src\body.html` when they change.
