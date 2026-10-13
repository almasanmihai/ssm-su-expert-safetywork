Add-Type -AssemblyName System.Drawing

function U([int]$code) {
	return [char]$code
}

$si = (U 0x0219) + "i"
$st = "Bucure" + (U 0x0219) + "ti"
$nat = "na" + (U 0x021B) + "ional" + (U 0x0103)

$bmp = New-Object System.Drawing.Bitmap 1200, 630
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g.Clear([System.Drawing.Color]::FromArgb(26, 22, 20))

$gold = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(215, 181, 50))
$yellow = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 222, 89))
$white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 255))
$sky = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(167, 223, 252))

$g.FillRectangle($gold, 0, 0, 16, 630)
$g.FillRectangle($gold, 0, 590, 1200, 40)

$root = Split-Path $PSScriptRoot -Parent
$logo = [System.Drawing.Image]::FromFile((Join-Path $root "public\logo.png"))
$g.DrawImage($logo, 56, 52, 72, 72)
$logo.Dispose()

$fontBrand = New-Object System.Drawing.Font "Segoe UI", 22, ([System.Drawing.FontStyle]::Bold)
$fontTitle = New-Object System.Drawing.Font "Segoe UI", 42, ([System.Drawing.FontStyle]::Bold)
$fontSub = New-Object System.Drawing.Font "Segoe UI", 18, ([System.Drawing.FontStyle]::Regular)

$g.DrawString("TCA SAFEWORK", $fontBrand, $yellow, 56, 170)
$g.DrawString("Serviciu extern SSM", $fontTitle, $white, 52, 230)
$g.DrawString("$si PSI / SU", $fontTitle, $white, 52, 300)
$g.DrawString("Abilitat ITM $st - acoperire $nat", $fontSub, $sky, 56, 400)

$encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$ep = New-Object System.Drawing.Imaging.EncoderParameters 1
$ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality, [long]88)
$out = Join-Path $root "public\images\og-cover.jpg"
$bmp.Save($out, $encoder, $ep)

$g.Dispose()
$bmp.Dispose()
Write-Host "saved $out"
