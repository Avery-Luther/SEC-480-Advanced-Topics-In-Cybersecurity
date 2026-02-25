function Get-480Banner(){
	$Banner = @"
   _                       _    
  /_\__   _____ _ __ _   _( )__ 
 //_\\ \ / / _ \ '__| | | |/ __|
/  _  \ V /  __/ |  | |_| |\__ \
\_/ \_/\_/ \___|_|   \__, ||___/
                     |___/      
.------..------..------.
|4.--. ||8.--. ||0.--. |
| :/\: || :/\: || :/\: |
| :\/: || :\/: || :\/: |
| '--'4|| '--'8|| '--'0|
``------'``------'``------'
 /`$`$   /`$`$   /`$`$     /`$`$ /`$`$          
| `$`$  | `$`$  | `$`$    |__/| `$`$          
| `$`$  | `$`$ /`$`$`$`$`$`$   /`$`$| `$`$  /`$`$`$`$`$`$`$
| `$`$  | `$`$|_  `$`$_/  | `$`$| `$`$ /`$`$_____/
| `$`$  | `$`$  | `$`$    | `$`$| `$`$|  `$`$`$`$`$`$ 
| `$`$  | `$`$  | `$`$ /`$`$| `$`$| `$`$ \____  `$`$
|  `$`$`$`$`$`$/  |  `$`$`$`$/| `$`$| `$`$ /`$`$`$`$`$`$`$/
 \______/    \___/  |__/|__/|_______/
"@

	Write-Host $Banner
}
function Connect-480Server([string] $vserver)
{
	$conn = $global:DefaultVIServer
	if ($conn){
		$msg = "Already connected to {0}" -f $conn
		Write-Host -ForegroundColor Green $msg
	}else
	{
		$conn = Connect-VIServer -Server $vserver
	}

}
function New-480Clone($ConfigPath)
{
	if ((Test-Path -Path $ConfigPath) -and (Get-Content -Raw -Path $ConfigPath | Test-Json))
	{
		$conf = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json
		$msg = "Using config at {0}" -f $ConfigPath
		Write-Host $msg
	} else 
	{
		Write-Host "Config path either doesn't exist or is empty"
	}
	if (($conf.OldVMName -eq $null) -or ((Get-VM -Location "480-avery" | Select-Object -ExpandProperty Name) -inotcontains $conf.OldVMName)){
		$operation = $true	
		While ($operation)
		{

			Get-VM -Location "480-avery" | Select Name | Out-String
			$OldVMName = Read-Host -Prompt "Which VM would you like to clone?"	
			$OldVM = Get-VM -Name $OldVMName
			if ($OldVM -eq $null)
			{
				Write-Host "The selected VM doesn't exist. Please enter one that does."
			} else
			{
				$operation = $false
			}
		}
	} else
	{
		$OldVMName = $conf.OldVMName
		$OldVM = Get-VM -Name $OldVMName 
	}
	#This may seem odd to not ask for a datastore, but I only have one datastore in my environment.
	#If this becomes an issue I will fix it
	$ds = Get-Datastore -Name 'datastore1'

	#Get the VMHost
	if (($conf.VMHost -eq $null) -or ((Get-VMHost -Location '480-avery' | Select-Object -ExpandProperty Name) -inotcontains $conf.VMHost))
	{
		# Get the VM host location
		$operation = $true
		While ($operation)
		{

			Write-Host "VM Hosts:"
			Get-VMHost -Location '480-avery'
			$VMHost = Read-Host -Prompt "Where would you like your VM?"
			if ($VMHost -eq $null)
			{
				Write-Host "Please enter a real vm host"
			} else 
			{
				$operation = $false
			}
		}
	} else 
	{
		$VMHost = $conf.VMHost
	}
	
	if (($conf.CloneName -eq $null) -or ((Get-VM -location $VMHost | Select-Object -ExpandProperty Name) -icontains $conf.CloneName))
	{
		#Gets the new vm name and checks to see if it already exists
		$operation = $true
		While ($operation)
		{
			$CloneName = Read-Host "Name of the new VM"
			if ((Get-VM -location $VMHost | Select-Object -ExpandProperty Name) -icontains $CloneName)
			{
				Write-Host "That name is taken. Please enter a different name"
			} else
			{
				$operation = $false
			}
		}
	} else
	{
		$CloneName = $conf.CloneName
	}
	
	if (($conf.LinkedOrFull -eq 1) -or ($conf.LinkedOrFull -eq 2))
	{
		$Choice = $conf.LinkedOrFull
	} else
	{
		#Linked or full clone selection  
		$Prompt = "`n"
		$Prompt += "Please choose your operation:`n"
		$Prompt += "1 - Linked Clone`n"
		$Prompt += "2 - Full Clone"
		Write-Host $Prompt | Out-String
		$Choice = Read-Host -Prompt "Choice"
	}	
	$operation = $true		
	While ($operation)
	{	
		# If there isn't a VM snapshot this will ask if you want to make a snapshot.	
		if ((Get-Snapshot -VM $OldVM | Measure-Object) -eq 0)			{
	
			$operation2 = $true
			While ($operation2)
			{
				if (($conf.TakeOldSnapshot -inotlike 'y') -or ($conf.TakeOldSnapshot -inotlike 'n'))
				{
					$TakeOldSnapshot = Read-Host "There are no Snapshots on this VM.`nWould you like to take a new snapshot (y/N)"
				} else {
					$TakeOldSnapshot = $conf.TakeOldSnapshot
				}
				if ($TakeOldSnapshot -ilike "y")
				{
					New-Snapshot -VM $OldVM -Name "base" -Description "Created with 480 Utils while creating a linked clone"
					$operation2 = $false
				} elseif ($TakeOldSnapshot -ilike "n")
				{
					$errormsg = Write-Host "Cannot create a linked clone without a snapshot."
					$operation2 = $false
					$operation = $false
					return $errormsg
				} else
				{
					Write-Host "Please enter a 'y' for yes or 'n' for no"
				}
			}
		}
		$operation2 = $true
		While ($operation2)
		{
			if ((Get-Snapshot -VM $OldVM | Select-Object -ExpandProperty Name) -contains $conf.OldSnapshotName)
			{
				$OldSnapshotName = $conf.OldSnapshotName
				$operation2 = $false 
			} else {
				$OldSnapshots = Get-Snapshot -VM $OldVM 
				Write-Host "Snapshots to link from:"
				Get-Snapshot -VM $OldVM | Select Name,Created | Format-Table -Wrap | Out-String
				$OldSnapshotName = Read-Host -Prompt "Which snapshot would you like to link from?"
				if ((Get-Snapshot -VM $OldVM | Select-Object -ExpandProperty Name) -contains $OldSnapshotName)
				{
					$operation2 = $false
				} else
				{
					Write-Host "Please enter a snapshot that exists"
				}
			}
		}
		$OldSnapshot = Get-Snapshot -VM $OldVM -Name $OldSnapshotName
		# Create the linked clone

		if($Choice -eq 1)
		{
			Write-Host "Creating Linked Clone"
			New-VM -VM $OldVM -ReferenceSnapshot $OldSnapshot -LinkedClone -Datastore $ds -VMHost $VMHost -Name $CloneName
			$operation = $false
		}
		if($Choice -eq 2)
		{
			Write-Host "Creating Full Clone"
			$TempLinkedName = $CloneName
			$TempLinkedName += ".temp"
			$LinkedVM = New-VM -VM $OldVM -LinkedClone -ReferenceSnapshot $OldSnapshot -Datastore $ds -VMHost $VMHost -Name $TempLinkedName
			New-VM -VM $LinkedVM -Datastore $ds -VMHost $VMHost -Name $CloneName	
			$LinkedVM | Remove-VM
			$operation = $false
		}
		New-Snapshot -VM (Get-VM -Name $CloneName) -Name "base"
			
	}
}

<#
function Get-480Info([string] $configpath){

}

function Reload-480Utils(){
	#This function is broken
	Remove-Module -Name 480Utils
	Import-Module './480Utils.psm1' -Force
}
#>
