# Builds the All Paws site.
#   docs\      full static site for GitHub Pages (index.html + site.css + site.js + img\)
#   artifact\  claude.ai preview: head+body with inline CSS/JS, images published alongside
# Photos: source\raw\*.jpg are mapped to friendly names below, resized with System.Drawing (no installs).
# ASCII only in this file (Windows PowerShell 5.1 reads BOM-less scripts as ANSI).
param([switch]$SkipImages)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
Add-Type -AssemblyName System.Drawing

$rover = 'https://www.rover.com/sit/emilyl32569'
$promo = 'https://www.rover.com/promos/emilyl32569/'

# friendly name = raw file, max long edge
$photos = [ordered]@{
  'logo'            = @('logo', 640)
  'logo-sm'         = @('logo', 128)
  'doodle-run'      = @('fb-04', 1100)
  'setter'          = @('fb-02', 1100)
  'doodle-pair'     = @('fb-01', 1100)
  'sitter-cavalier' = @('fb-03', 1100)
  'emily-baylie'    = @('fb-05', 1500)
  'senior-lambchop' = @('fb-06', 1100)
  'floor-cuddle'    = @('fb-07', 1100)
  'lab-walk'        = @('fb-08', 1100)
  'dogpark-pair'    = @('ig-2025-04-07', 1100)
  'black-dog'       = @('ig-2025-04-11', 1100)
  'belly-rubs'      = @('ig-2025-04-29', 1100)
  'sleepy-plushies' = @('ig-2025-05-17', 1100)
  'ice-cream'       = @('ig-2025-05-24', 1100)
  'sitter-dog-bed'  = @('ig-2025-06-21', 1100)
  'aussie-bed'      = @('ig-2025-08-05', 1100)
  'sitter-cat'      = @('ig-2026-07-07', 1100)
  'shihtzu-grass'   = @('ig-2026-07-13', 1100)
  'shihtzu-couch'   = @('ig-2026-07-15', 1100)
}

$docs = Join-Path $root 'docs'
$art  = Join-Path $root 'artifact'
foreach ($d in @($docs, "$docs\img", $art, "$art\img")) { New-Item -ItemType Directory -Force $d | Out-Null }

$jpeg = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$ep = New-Object System.Drawing.Imaging.EncoderParameters 1
$ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), ([long]80)

$dims = @{}
foreach ($name in $photos.Keys) {
  $src = Join-Path $root ("source\raw\" + $photos[$name][0] + '.jpg')
  $max = [int]$photos[$name][1]
  $out = Join-Path $docs "img\$name.jpg"
  $img = [System.Drawing.Image]::FromFile($src)
  try {
    $scale = [math]::Min(1.0, $max / [double][math]::Max($img.Width, $img.Height))
    $w = [int][math]::Round($img.Width * $scale); $h = [int][math]::Round($img.Height * $scale)
    $dims[$name] = @($w, $h)
    if (-not $SkipImages -or -not (Test-Path $out)) {
      $bmp = New-Object System.Drawing.Bitmap $w, $h
      $g = [System.Drawing.Graphics]::FromImage($bmp)
      $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
      $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
      $g.DrawImage($img, 0, 0, $w, $h)
      $bmp.Save($out, $jpeg, $ep)
      $g.Dispose(); $bmp.Dispose()
    }
  } finally { $img.Dispose() }
  Copy-Item $out (Join-Path $art "img\$name.jpg") -Force
}

$utf8 = New-Object System.Text.UTF8Encoding $false
function Read-Text($p) { [System.IO.File]::ReadAllText((Join-Path $root $p), $utf8) }

$icons = @{}
Get-ChildItem (Join-Path $root 'src\icons') -Filter *.svg | ForEach-Object {
  $svg = [System.IO.File]::ReadAllText($_.FullName, $utf8).Trim()
  $icons[$_.BaseName] = $svg -replace '^<svg ', '<svg class="icon" aria-hidden="true" focusable="false" '
}

function Expand-Tokens([string]$html) {
  $html = $html.Replace('{{rover}}', $rover).Replace('{{promo}}', $promo).Replace('{{year}}', (Get-Date).Year.ToString())
  $star = $icons['star-fill']
  $html = $html.Replace('{{stars}}', ($star * 5))
  $html = [regex]::Replace($html, '\{\{icon:([a-z0-9-]+)\}\}', {
    param($m) $k = $m.Groups[1].Value
    if (-not $icons.ContainsKey($k)) { throw "Missing icon: $k" }
    $icons[$k]
  })
  # {{img:name|alt|extra attrs and/or eager}}
  $html = [regex]::Replace($html, '\{\{img:([a-z0-9-]+)\|([^|}]*)(?:\|([^}]*))?\}\}', {
    param($m)
    $n = $m.Groups[1].Value; $alt = $m.Groups[2].Value; $extra = $m.Groups[3].Value
    if (-not $dims.ContainsKey($n)) { throw "Missing photo: $n" }
    $load = 'loading="lazy" decoding="async"'
    if ($extra -match '\beager\b') { $load = 'decoding="async"'; $extra = ($extra -replace '\beager\b', '').Trim() }
    $alt = $alt.Replace('"', '&quot;')
    "<img src=""img/$n.jpg"" width=""$($dims[$n][0])"" height=""$($dims[$n][1])"" alt=""$alt"" $load $extra>".Replace('  ', ' ').Replace(' >', '>')
  })
  if ($html -match '\{\{') { throw "Unexpanded token near: " + $html.Substring($html.IndexOf('{{'), 40) }
  return $html
}

$head = Expand-Tokens (Read-Text 'src\head.html')
$body = Expand-Tokens (Read-Text 'src\body.html')
$css  = Read-Text 'src\site.css'
$js   = Read-Text 'src\site.js'

# Guard: no em or en dashes anywhere visible
foreach ($pair in @(@('head', $head), @('body', $body))) {
  if ($pair[1].IndexOf([char]0x2013) -ge 0 -or $pair[1].IndexOf([char]0x2014) -ge 0) { throw "Dash character found in $($pair[0])" }
}

$page = "<!doctype html>`n<html lang=""en"">`n<head>`n<meta charset=""utf-8"">`n<meta name=""viewport"" content=""width=device-width, initial-scale=1, viewport-fit=cover"">`n" +
  $head + "<link rel=""stylesheet"" href=""site.css"">`n</head>`n<body>`n" + $body + "`n<script src=""site.js""></script>`n</body>`n</html>`n"
[System.IO.File]::WriteAllText((Join-Path $docs 'index.html'), $page, $utf8)
[System.IO.File]::WriteAllText((Join-Path $docs 'site.css'), $css, $utf8)
[System.IO.File]::WriteAllText((Join-Path $docs 'site.js'), $js, $utf8)
[System.IO.File]::WriteAllText((Join-Path $docs '.nojekyll'), '', $utf8)

$artHtml = $head + "<style>`n" + $css + "</style>`n" + $body + "`n<script>`n" + $js + "</script>`n"
[System.IO.File]::WriteAllText((Join-Path $art 'index.html'), $artHtml, $utf8)

$kb = [math]::Round(((Get-ChildItem "$docs\img" | Measure-Object Length -Sum).Sum) / 1KB)
"Built docs\ and artifact\ ($($photos.Count) photos, $kb KB of images)"
