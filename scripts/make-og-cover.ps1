# Builds public/images/og-cover.jpg: the share photo plus the hero title.
# Source photo (no text) lives at scripts/og-photo.jpg so reruns do not stack text.
Add-Type -AssemblyName System.Drawing

function U([int]$code) { return [char]$code }

function Read-Be16([byte[]]$b, [int]$o) {
	$tmp = [byte[]]::new(2)
	[Array]::Copy($b, $o, $tmp, 0, 2)
	[Array]::Reverse($tmp)
	return [BitConverter]::ToUInt16($tmp, 0)
}

function Read-Be32([byte[]]$b, [int]$o) {
	$tmp = [byte[]]::new(4)
	[Array]::Copy($b, $o, $tmp, 0, 4)
	[Array]::Reverse($tmp)
	return [BitConverter]::ToUInt32($tmp, 0)
}

function Write-Be16([IO.BinaryWriter]$w, [uint16]$v) {
	$bytes = [BitConverter]::GetBytes($v)
	[Array]::Reverse($bytes)
	$w.Write($bytes)
}

function Write-Be32([IO.BinaryWriter]$w, [uint32]$v) {
	$bytes = [BitConverter]::GetBytes($v)
	[Array]::Reverse($bytes)
	$w.Write($bytes)
}

function Convert-WoffToTtf([string]$woffPath, [string]$ttfPath) {
	$bytes = [IO.File]::ReadAllBytes($woffPath)
	$numTables = Read-Be16 $bytes 12
	$tables = @()
	for ($i = 0; $i -lt $numTables; $i++) {
		$o = 44 + ($i * 20)
		$tag = [Text.Encoding]::ASCII.GetString($bytes, $o, 4)
		$offset = Read-Be32 $bytes ($o + 4)
		$comp = Read-Be32 $bytes ($o + 8)
		$orig = Read-Be32 $bytes ($o + 12)
		$checksum = Read-Be32 $bytes ($o + 16)
		$compBytes = [byte[]]::new($comp)
		[Array]::Copy($bytes, $offset, $compBytes, 0, $comp)
		if ($comp -eq $orig) {
			$data = $compBytes
		} else {
			$payload = [byte[]]::new($comp - 6)
			[Array]::Copy($compBytes, 2, $payload, 0, $payload.Length)
			$ms = New-Object IO.MemoryStream(,$payload)
			$ds = New-Object IO.Compression.DeflateStream($ms, [IO.Compression.CompressionMode]::Decompress)
			$outMs = New-Object IO.MemoryStream
			$ds.CopyTo($outMs)
			$ds.Dispose()
			$ms.Dispose()
			$data = $outMs.ToArray()
			$outMs.Dispose()
			if ($data.Length -ne $orig) {
				throw "Font table $tag inflated to $($data.Length), expected $orig"
			}
		}
		$pad = (4 - ($data.Length % 4)) % 4
		if ($pad -gt 0) {
			$padded = [byte[]]::new($data.Length + $pad)
			[Array]::Copy($data, $padded, $data.Length)
			$data = $padded
		}
		$tables += [pscustomobject]@{ Tag = $tag; Checksum = $checksum; Orig = $orig; Data = $data }
	}
	$tables = @($tables | Sort-Object Tag)
	$n = [uint16]$tables.Count
	$entrySelector = 0
	$searchRange = 1
	while (($searchRange * 2) -le $n) { $searchRange *= 2; $entrySelector++ }
	$searchRange = [uint16]($searchRange * 16)
	$entrySelector = [uint16]$entrySelector
	$rangeShift = [uint16]($n * 16 - $searchRange)

	$msOut = New-Object IO.MemoryStream
	$w = New-Object IO.BinaryWriter($msOut)
	Write-Be32 $w (Read-Be32 $bytes 4)
	Write-Be16 $w $n
	Write-Be16 $w $searchRange
	Write-Be16 $w $entrySelector
	Write-Be16 $w $rangeShift
	$dataOffset = [uint32](12 + (16 * $n))
	foreach ($t in $tables) {
		$tagBytes = [Text.Encoding]::ASCII.GetBytes($t.Tag)
		$w.Write($tagBytes)
		Write-Be32 $w ([uint32]$t.Checksum)
		Write-Be32 $w $dataOffset
		Write-Be32 $w ([uint32]$t.Orig)
		$dataOffset += [uint32]$t.Data.Length
	}
	foreach ($t in $tables) { $w.Write($t.Data) }
	$w.Flush()
	[IO.File]::WriteAllBytes($ttfPath, $msOut.ToArray())
	$w.Dispose()
	$msOut.Dispose()
}

function Get-SyneFile([int]$weight) {
	$dir = Join-Path $env:TEMP "tcasafework-syne"
	New-Item -ItemType Directory -Force -Path $dir | Out-Null
	$ttf = Join-Path $dir "syne-$weight.ttf"
	if (Test-Path $ttf) { return $ttf }
	$css = curl.exe -sL -A "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:27.0) Gecko/20100101 Firefox/27.0" "https://fonts.googleapis.com/css2?family=Syne:wght@${weight}&display=swap"
	$url = [regex]::Match($css, "https://fonts.gstatic.com/s/syne/[^)]+").Value
	if (-not $url) { throw "Could not find Syne $weight download URL" }
	$woff = Join-Path $dir "syne-$weight.woff"
	curl.exe -sL $url -o $woff
	Convert-WoffToTtf $woff $ttf
	return $ttf
}

$root = Split-Path $PSScriptRoot -Parent
$source = Join-Path $PSScriptRoot "og-photo.jpg"
$out = Join-Path $root "public\images\og-cover.jpg"
if (-not (Test-Path $source)) {
	Copy-Item $out $source
}

$photo = [System.Drawing.Image]::FromFile($source)
$bmp = New-Object System.Drawing.Bitmap 1200, 630
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.DrawImage($photo, 0, 0, 1200, 630)
$photo.Dispose()

$rect = New-Object System.Drawing.Rectangle 0, 0, 1200, 630
$ink = { param($a) [System.Drawing.Color]::FromArgb($a, 26, 22, 20) }

$horizontal = New-Object System.Drawing.Drawing2D.LinearGradientBrush $rect, (& $ink 224), (& $ink 71), 15
$blend = New-Object System.Drawing.Drawing2D.ColorBlend 3
$blend.Colors = @((& $ink 224), (& $ink 158), (& $ink 56))
$blend.Positions = @(0.0, 0.42, 1.0)
$horizontal.InterpolationColors = $blend
$g.FillRectangle($horizontal, $rect)
$horizontal.Dispose()

$vertical = New-Object System.Drawing.Drawing2D.LinearGradientBrush $rect, (& $ink 40), (& $ink 120), 90
$g.FillRectangle($vertical, $rect)
$vertical.Dispose()

$pfc700 = New-Object System.Drawing.Text.PrivateFontCollection
$pfc800 = New-Object System.Drawing.Text.PrivateFontCollection
$pfc700.AddFontFile((Get-SyneFile 700))
$pfc800.AddFontFile((Get-SyneFile 800))
$fontBrand = New-Object System.Drawing.Font($pfc800.Families[0], 30, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fontTitle = New-Object System.Drawing.Font($pfc700.Families[0], 58, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

$yellow = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 222, 89))
$white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
$shadow = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(90, 0, 0, 0))
$format = [System.Drawing.StringFormat]::GenericTypographic
$format.FormatFlags = [System.Drawing.StringFormatFlags]::MeasureTrailingSpaces

function Draw-Tracked([string]$text, $font, $brush, [single]$x, [single]$y, [single]$tracking) {
	$cursor = $x
	foreach ($ch in $text.ToCharArray()) {
		$s = [string]$ch
		$g.DrawString($s, $font, $brush, $cursor, $y, $format)
		$cursor += $g.MeasureString($s, $font, [int]::MaxValue, $format).Width + $tracking
	}
}

$title = "Un singur furnizor pentru SSM " + (U 0x0219) + "i PSI/SU"
$titleRect = New-Object System.Drawing.RectangleF 72, 268, 500, 280
$shadowRect = New-Object System.Drawing.RectangleF 74, 271, 500, 280

Draw-Tracked "TCA SAFEWORK" $fontBrand $shadow 74 214 1.2
Draw-Tracked "TCA SAFEWORK" $fontBrand $yellow 72 212 1.2
$g.DrawString($title, $fontTitle, $shadow, $shadowRect, $format)
$g.DrawString($title, $fontTitle, $white, $titleRect, $format)

$encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$ep = New-Object System.Drawing.Imaging.EncoderParameters 1
$ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality, [long]90)
$bmp.Save($out, $encoder, $ep)

$g.Dispose()
$bmp.Dispose()
$fontBrand.Dispose()
$fontTitle.Dispose()
$yellow.Dispose()
$white.Dispose()
$shadow.Dispose()
Write-Host "saved $out"
