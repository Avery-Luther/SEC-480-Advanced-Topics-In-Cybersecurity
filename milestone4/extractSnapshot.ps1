$vserver="vcenter.avery.local"
Connect-VIServer($vserver)

Write-Host "Existing VMs:"
Get-VM -Location "480-avery" | Select Name
$basevmname = Read-Host -Prompt "Which VM would you like to extract from?"
$vm=Get-VM -Name $basevmname

Write-Host "Snapshots:"
Get-Snapshot -VM $vm | Select Name
$basesnapshotname = Read-Host -Prompt "Which snapshot do you want to extract?"
$newvmname = Read-Host -Prompt "New VM name" 


$snapshot=Get-Snapshot -VM $vm -Name $basesnapshotname
$vmhost=Get-VMHost -Name "super26.avery.local"
$ds=Get-DataStore -Name datastore1
$linkedname = "{0}.linked" -f $vm.name 

$linkedvm = New-VM -LinkedClone -Name $linkedname -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds
$newvm = New-VM -Name $newvmname -VM $linkedvm -VMHost $vmhost -Datastore $ds

$newvm | new-snapshot -Name "Base"

$linkedvm | Remove-VM
