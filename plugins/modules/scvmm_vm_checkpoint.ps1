# PowerShell Module Logic

# Requires -Module Microsoft.SystemCenter.VirtualMachineManager
# Requires -Version 5.1

$ErrorActionPreference = "Stop"

$params = Parse-Args $args -operators @{
    state = @{ default = "present"; choices = "present", "absent", "restored" }
}

$name = Get-AnsibleParam -obj $params -name "name" -type "str"
$vm_name = Get-AnsibleParam -obj $params -name "vm_name" -type "str" -failifempty $true
$description = Get-AnsibleParam -obj $params -name "description" -type "str"
$state = Get-AnsibleParam -obj $params -name "state" -type "str" -default "present"

$result = @{
    changed = $false
}

function Get-CheckpointObject {
    param($VM, $Name)
    $checkpoints = Get-SCVMCheckpoint -VM $VM | Where-Object { $_.Name -eq $Name }
    return $checkpoints
}

function Convert-CheckpointToHashtable {
    param($Checkpoint)
    return @{
        name = $Checkpoint.Name
        description = $Checkpoint.Description
        added_time = $Checkpoint.AddedTime.ToString("yyyy-MM-ddTHH:mm:ssZ")
        checkpoint_id = $Checkpoint.CheckpointID.ToString()
        vm_name = $Checkpoint.VM.Name
        is_latest = $Checkpoint.IsLatest
    }
}

try {
    # Get the VM object
    $vm = Get-SCVM -Name $vm_name
    if (-not $vm) {
        Fail-Json -obj $result -message "Virtual machine '$vm_name' not found."
    }

    # Find the checkpoint
    $checkpoint = Get-CheckpointObject -VM $vm -Name $name

    if ($state -eq "present") {
        if (-not $checkpoint) {
            # Create new checkpoint
            $result.changed = $true
            if (-not $params.ansible_check_mode) {
                $checkpoint = New-SCVMCheckpoint -VM $vm -Name $name -Description $description
            }
        }
        else {
            # Check for updates (description)
            if ($null -ne $description -and $checkpoint.Description -ne $description) {
                $result.changed = $true
                if (-not $params.ansible_check_mode) {
                    $checkpoint = Set-SCVMCheckpoint -VMCheckpoint $checkpoint -Description $description
                }
            }
        }
    }
    elseif ($state -eq "absent") {
        if ($checkpoint) {
            $result.changed = $true
            if (-not $params.ansible_check_mode) {
                Remove-SCVMCheckpoint -VMCheckpoint $checkpoint -Confirm:$false
                $checkpoint = $null
            }
        }
    }
    elseif ($state -eq "restored") {
        if (-not $checkpoint) {
            Fail-Json -obj $result -message "Checkpoint '$name' for VM '$vm_name' not found. Cannot restore."
        }

        # Restore is always considered a change if we perform it. 
        # Note: Determining if the VM is *already* in the state of that checkpoint is complex in VMM 
        # as it doesn't strictly have a "current" pointer like VMware in some views, 
        # but Restore-SCVMCheckpoint is an action.
        $result.changed = $true
        if (-not $params.ansible_check_mode) {
            Restore-SCVMCheckpoint -VMCheckpoint $checkpoint
        }
    }

    if ($checkpoint) {
        $result.checkpoint = Convert-CheckpointToHashtable -Checkpoint $checkpoint
    }

    Exit-Json -obj $result
}
catch {
    Fail-Json -obj $result -message $_.Exception.Message
}
