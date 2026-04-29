$480Path = Join-Path $PSScriptRoot "../../480Utils.psm1"
Import-Module $480Path

Connect-480Server vcenter.avery.local

$Password = Read-Host -AsSecureString -Prompt "Password"

Set-480WinIP -VMName "blue.dc1" -IP "10.0.5.5" -SNM "255.255.255.0" -DNS "10.0.5.2" -DefaultGateway "10.0.5.2" -GuestUser "deployer" -GuestPassword $Password
