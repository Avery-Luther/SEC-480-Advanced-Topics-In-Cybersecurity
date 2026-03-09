$480Path = Join-Path $PSScriptRoot "../480Utils.psm1"
Import-Module $480Path

Connect-480Server vcenter.avery.local

$BlueNetworkConfigPath = Join-Path $PSScriptRoot "blueNetwork.json"
$BlueFwConfigPath = Join-Path $PSScriptRoot "blueFW.json"
$BlueNetChangeConfigPath = Join-Path $PSScriptRoot "blueFwNet.json"

New-480Clone $BlueFwConfigPath
New-480Network $BlueNetworkConfigPath
Read-Host -Prompt "Show New Blue Network"
Get-480IP dc1
Start-480VM ubuntuserver.test
Read-Host "Show ubuntuserver.test powered on"
Stop-480VM ubuntuserver.test
