$vserver="vcenter.avery.local"
Connect-VIServer($vserver)

Write-Host "Existing VMs:"
Get-VM -Location "480-avery" | Select Name
$basevmname = Read-Host -Prompt "Which VM would you like to clone from?"
$vm=Get-VM -Name $basevmname
Get-Snapshot -VM $vm | Select Name
$snapshot = Read-Host -Prompt "Which snapshot would you like to use for reference?"
$newvmname = Read-Host -Prompt "New VM name" 



$vmhost=Get-VMHost -Name "super26.avery.local"
$ds=Get-DataStore -Name datastore1


$linkedvm = New-VM -LinkedClone -Name $newvmname -VM $vm -VMHost $vmhost -Datastore $ds -ReferenceSnapshot $snapshot


$linkedvm


