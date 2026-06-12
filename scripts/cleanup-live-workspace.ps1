# Remove duplicate nested folders and stale drift from live ~/.openclaw workspaces

$ErrorActionPreference = "Stop"

$ws = "$env:USERPROFILE\.openclaw\workspace"

$wsOps = "$env:USERPROFILE\.openclaw\workspace-ops"



$remove = @(

    "$ws\calendar\calendar",

    "$ws\skills\skills",

    "$ws\_run-calendar-script.ps1",

    "$ws\services.md"

)

foreach ($p in $remove) {

    if (Test-Path $p) {

        Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue

        Write-Host "Removed $p"

    }

}



# Remove boilerplate Ops TOOLS if it looks like OpenClaw template (re-sync replaces with VisionsCraft version)

$opsTools = "$wsOps\TOOLS.md"

if (Test-Path $opsTools) {

    $t = Get-Content $opsTools -Raw

    if ($t -match "What Goes Here" -or $t -match "Skills define") {

        Remove-Item $opsTools -Force

        Write-Host "Removed stale Ops TOOLS.md template"

    }

}



Write-Host "Cleanup complete."

