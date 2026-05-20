#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_compute

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = 'str' }
        vm_name = @{ type = 'str' }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$vm_name = $module.Params.vm_name
$vmm_server = $module.Params.vmm_server

try {
    $getParams = @{}
    if ($vmm_server) { $getParams.VMMServer = $vmm_server }

    $checkpoints = @()

    if ($vm_name) {
        $vmParams = $getParams.Clone()
        $vmParams.Name = $vm_name
        $vm = Get-SCVirtualMachine @vmParams -ErrorAction SilentlyContinue

        if (-not $vm) {
            $module.FailJson("Virtual machine '$vm_name' not found.")
        }

        $checkpoints = Get-SCVMCheckpoint -VM $vm
    }
    else {
        $checkpoints = Get-SCVMCheckpoint @getParams
    }

    if ($name) {
        if ($name.Contains('*')) {
            $checkpoints = $checkpoints | Where-Object { $_.Name -like $name }
        }
        else {
            $checkpoints = $checkpoints | Where-Object { $_.Name -eq $name }
        }
    }

    $module.Result.checkpoints = $checkpoints | ForEach-Object { Get-SCVMMVMCheckpointInfo -Checkpoint $_ }
}
catch {
    $module.FailJson("An error occurred: $($_.Exception.Message)", $_)
}

$module.ExitJson()
