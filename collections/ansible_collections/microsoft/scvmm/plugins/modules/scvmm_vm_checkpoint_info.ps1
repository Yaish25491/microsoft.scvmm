#!powershell
# Copyright: (c) 2024, Ansible Project
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module VirtualMachineManager
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -CSharpUtil Ansible.Basic

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = "str" }
        vm_name = @{ type = "str" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$vm_name = $module.Params.vm_name

$module.Result.checkpoints = @()

try {
    # Import SCVMM module using utility
    Import-SCVMMModule -Module $module

    $checkpoints = @()

    if ($vm_name) {
        $vms = Get-SCVirtualMachine -Name $vm_name -ErrorAction SilentlyContinue
        if ($vms) {
            foreach ($vm in $vms) {
                $checkpoints += Get-SCVMCheckpoint -VM $vm -ErrorAction SilentlyContinue
            }
        }
    }
    else {
        $checkpoints = Get-SCVMCheckpoint -ErrorAction SilentlyContinue
    }

    if ($checkpoints) {
        $checkpointsArray = @($checkpoints)
        
        # Filter by checkpoint name if provided
        if ($name) {
            $checkpointsArray = $checkpointsArray | Where-Object { $_.Name -like $name }
        }

        foreach ($checkpoint in $checkpointsArray) {
            $module.Result.checkpoints += Get-SCVMMCheckpointInfo -Checkpoint $checkpoint
        }
    }
}
catch {
    $module.FailJson("Failed to gather VM checkpoint info: $($_.Exception.Message)", $_)
}

$module.ExitJson()
