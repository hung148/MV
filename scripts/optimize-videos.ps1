# Run with FFmpeg on PATH or pass a portable executable. Originals are preserved.
param([string]$FfmpegPath = 'ffmpeg')
$ErrorActionPreference = 'Stop'
$encoder = (Get-Command $FfmpegPath -ErrorAction Stop).Source
$projectRoot = Split-Path $PSScriptRoot -Parent
$videoDirectory = Join-Path $projectRoot 'assets/videos'
$outputDirectory = Join-Path $projectRoot 'build/video-exports'
New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
foreach ($clip in Get-ChildItem -LiteralPath $videoDirectory -Filter '*.mp4' -File) {
  $outputPath = Join-Path $outputDirectory $clip.Name
  & $encoder -hide_banner -loglevel warning -n -i $clip.FullName -an -vf "scale=w='min(1280,iw)':h=-2,fps=fps='min(source_fps,30)'" -c:v libx264 -preset medium -crf 23 -pix_fmt yuv420p -movflags +faststart $outputPath
  if ($LASTEXITCODE -ne 0) { throw "Encoding failed for $($clip.Name)" }
}
