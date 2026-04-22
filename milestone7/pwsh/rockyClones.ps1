$480Path = Join-Path $PSScriptRoot "../../480Utils.psm1"
Import-Module $480Path

Connect-480Server('vcenter.avery.loval')
$RockyConfigPath = Join-Path $PSScriptRoot "./cloneRocky.json"
for ($i=0; $i -lt 3; $i++){
#	New-480Clone($RockyConfigPath)
	Set-480Network($RockyConfigPath)
}
