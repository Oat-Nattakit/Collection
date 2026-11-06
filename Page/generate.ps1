# Scan ../Resource and write data.js (list of folders + images) for index.html
# Usage: double-click generate.bat, or run:  powershell -ExecutionPolicy Bypass -File generate.ps1

$ErrorActionPreference = 'Stop'
$pageDir     = $PSScriptRoot
$resourceDir = Join-Path $pageDir '..\Resource'
$exts        = @('.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp', '.avif')

$items = @()
Get-ChildItem -LiteralPath $resourceDir -Directory | Sort-Object Name | ForEach-Object {
    $files = @(Get-ChildItem -LiteralPath $_.FullName -File |
        Where-Object { $exts -contains $_.Extension.ToLower() } |
        ForEach-Object { $_.Name })
    $items += [pscustomobject]@{ folder = $_.Name; images = $files }
}

$json = ConvertTo-Json -InputObject @($items) -Depth 5 -Compress
$out  = "window.COLLECTION = $json;`n"
[System.IO.File]::WriteAllText((Join-Path $pageDir 'data.js'), $out, (New-Object System.Text.UTF8Encoding $false))

Write-Host ("Wrote data.js: {0} folders, {1} images" -f $items.Count, ($items | ForEach-Object { $_.images.Count } | Measure-Object -Sum).Sum)
