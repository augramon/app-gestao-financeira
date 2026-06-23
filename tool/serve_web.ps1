# Servidor estatico para visualizar build/web localmente.
# Usa .NET HttpListener (in-process no powershell.exe, assinado -> permitido pelo Smart App Control).
$ErrorActionPreference = 'Stop'
$root = Join-Path (Split-Path $PSScriptRoot -Parent) 'build\web'
$prefix = 'http://localhost:8080/'

$mime = @{
  '.html'='text/html; charset=utf-8'; '.htm'='text/html; charset=utf-8';
  '.js'='application/javascript'; '.mjs'='application/javascript';
  '.css'='text/css'; '.json'='application/json'; '.map'='application/json';
  '.png'='image/png'; '.jpg'='image/jpeg'; '.jpeg'='image/jpeg';
  '.gif'='image/gif'; '.svg'='image/svg+xml'; '.ico'='image/x-icon';
  '.wasm'='application/wasm'; '.ttf'='font/ttf'; '.otf'='font/otf';
  '.woff'='font/woff'; '.woff2'='font/woff2'; '.bin'='application/octet-stream';
  '.symbols'='text/plain'
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
$listener.Start()
Write-Output "Servindo $root em $prefix"

while ($listener.IsListening) {
  try {
    $ctx = $listener.GetContext()
    $rel = $ctx.Request.Url.AbsolutePath
    if ($rel -eq '/' -or [string]::IsNullOrEmpty($rel)) { $rel = '/index.html' }
    $rel = [System.Uri]::UnescapeDataString($rel)
    $path = Join-Path $root ($rel.TrimStart('/') -replace '/', '\')
    if (-not (Test-Path $path -PathType Leaf)) { $path = Join-Path $root 'index.html' }  # SPA fallback
    $ext = [System.IO.Path]::GetExtension($path).ToLower()
    $ct = $mime[$ext]; if (-not $ct) { $ct = 'application/octet-stream' }
    $bytes = [System.IO.File]::ReadAllBytes($path)
    $ctx.Response.ContentType = $ct
    $ctx.Response.Headers.Add('Cache-Control','no-store, no-cache, must-revalidate')
    $ctx.Response.Headers.Add('Cross-Origin-Opener-Policy','same-origin')
    $ctx.Response.Headers.Add('Cross-Origin-Embedder-Policy','require-corp')
    $ctx.Response.ContentLength64 = $bytes.Length
    $ctx.Response.OutputStream.Write($bytes,0,$bytes.Length)
    $ctx.Response.OutputStream.Close()
  } catch {
    try { $ctx.Response.StatusCode = 500; $ctx.Response.Close() } catch {}
  }
}
