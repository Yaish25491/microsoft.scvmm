#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm_storage

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        classification = @{ type = 'str' }
        description = @{ type = 'str' }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$classification_name = $module.Params.classification
$description = $module.Params.description
$vmm_server = $module.Params.vmm_server

try {
    $get_params = @{ Name = $name; ErrorAction = "SilentlyContinue" }
    if ($null -ne $vmm_server) { $get_params["VMMServer"] = $vmm_server }
    $pool = Get-SCStoragePool @get_params

    if (-not $pool) {
        $module.FailJson("Storage pool '$name' not found. This module manages existing storage pools.")
    }

    $changed = $false
    $update_params = @{ StoragePool = $pool; ErrorAction = "Stop" }

    if ($null -ne $description -and $pool.Description -ne $description) {
        $update_params.Description = $description
        $changed = $true
    }

    if ($null -ne $classification_name) {
        $classification_get_params = @{ Name = $classification_name; ErrorAction = "SilentlyContinue" }
        if ($null -ne $vmm_server) { $classification_get_params["VMMServer"] = $vmm_server }
        $classification = Get-SCStorageClassification @classification_get_params

        if (-not $classification) {
            $module.FailJson("Storage classification '$classification_name' not found.")
        }
        if ($pool.Classification.Name -ne $classification_name) {
            $update_params.Classification = $classification
            $changed = $true
        }
    }

    if ($changed) {
        if (-not $module.CheckMode) {
            $pool = Set-SCStoragePool @update_params
        }
    }

    $module.Result.changed = $changed
    $module.Result.storage_pool = Get-SCVMMStoragePoolInfo -StoragePool $pool
}
catch {
    $module.FailJson("Failed to update storage pool: $($_.Exception.Message)", $_)
}

$module.ExitJson()
