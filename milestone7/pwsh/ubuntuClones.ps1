$480Path = Join-Path $PSScriptRoot "../../480Utils.psm1"
Import-Module $480Path

Connect-480Server('vcenter.avery.loval')
$ConfigPath = Join-Path $PSScriptRoot "./cloneUbuntu.json"
for ($i=0; $i -lt 2; $i++){
	New-480Clone($ConfigPath)
	Set-480Network($ConfigPath)
}
