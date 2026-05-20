#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_compute

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        vm_name = @{ type = 'str'; required = $true }
        description = @{ type = 'str' }
        state = @{ type = 'str'; default = 'present'; choices = @('present', 'absent', 'restored') }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$vm_name = $module.Params.vm_name
$description = $module.Params.description
$state = $module.Params.state
$vmm_server = $module.Params.vmm_server

$module.Result.changed = $false

try {
    $getParams = @{}
    if ($vmm_server) { $getParams.VMMServer = $vmm_server }

    $vmParams = $getParams.Clone()
    $vmParams.Name = $vm_name
    $vm = Get-SCVirtualMachine @vmParams -ErrorAction SilentlyContinue

    if (-not $vm) {
        $module.FailJson("Virtual machine '$vm_name' not found.")
    }

    $checkpoint = Get-SCVMCheckpoint -VM $vm | Where-Object { $_.Name -eq $name }

    if ($state -eq 'present') {
        if (-not $checkpoint) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                $checkpoint = New-SCVMCheckpoint -VM $vm -Name $name -Description $description -ErrorAction Stop
            }
        }
        else {
            if ($null -ne $description -and $checkpoint.Description -ne $description) {
                $module.Result.changed = $true
                if (-not $module.CheckMode) {
                    $checkpoint = Set-SCVMCheckpoint -VMCheckpoint $checkpoint -Description $description -ErrorAction Stop
                }
            }
        }
    }
    elseif ($state -eq 'absent') {
        if ($checkpoint) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                Remove-SCVMCheckpoint -VMCheckpoint $checkpoint -Confirm:$false -ErrorAction Stop
                $checkpoint = $null
            }
        }
    }
    elseif ($state -eq 'restored') {
        if (-not $checkpoint) {
            $module.FailJson("Checkpoint '$name' for VM '$vm_name' not found. Cannot restore.")
        }
        $module.Result.changed = $true
        if (-not $module.CheckMode) {
            Restore-SCVMCheckpoint -VMCheckpoint $checkpoint -ErrorAction Stop
        }
    }

    if ($checkpoint) {
        $module.Result.checkpoint = @{
            name = $checkpoint.Name
            description = $checkpoint.Description
            added_time = $checkpoint.AddedTime.ToString("yyyy-MM-ddTHH:mm:ssZ")
            checkpoint_id = $checkpoint.CheckpointID.ToString()
            vm_name = $checkpoint.VM.Name
            is_latest = $checkpoint.IsLatest
        }
    }
}
catch {
    $module.FailJson("An error occurred: $($_.Exception.Message)", $_)
}

$module.ExitJson()
