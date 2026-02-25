$480Path = Join-Path $PSScriptRoot "480Utils.psm1"
Import-Module $480Path

Connect-480Server vcenter.avery.local
Get-480Banner

$ConfigPath = Join-Path $PSScriptRoot "cloneVyos.json"

New-480Clone $ConfigPath
