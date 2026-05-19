#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        cpu_count = @{ type = 'int' }
        memory_mb = @{ type = 'int' }
        storage_gb = @{ type = 'int' }
        vm_count = @{ type = 'int' }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$cpu_count = $module.Params.cpu_count
$memory_mb = $module.Params.memory_mb
$storage_gb = $module.Params.storage_gb
$vm_count = $module.Params.vm_count

try {
    $cloud = Get-SCCloud -Name $name -ErrorAction SilentlyContinue
    if (-not $cloud) {
        $module.FailJson("Cloud '$name' not found.")
    }

    $current_capacity = Get-SCCloudCapacity -Cloud $cloud

    $changed = $false
    $update_params = @{}

    if ($null -ne $cpu_count -and $current_capacity.CPUCount -ne $cpu_count) { $update_params.CPUCount = $cpu_count; $changed = $true }
    if ($null -ne $memory_mb -and $current_capacity.Memory -ne $memory_mb) { $update_params.Memory = $memory_mb; $changed = $true }
    if ($null -ne $storage_gb -and $current_capacity.Storage -ne $storage_gb) { $update_params.Storage = $storage_gb; $changed = $true }
    if ($null -ne $vm_count -and $current_capacity.VMCount -ne $vm_count) { $update_params.VMCount = $vm_count; $changed = $true }

    if ($changed) {
        if (-not $module.CheckMode) {
            $job_id = [Guid]::NewGuid()
            Set-SCCloudCapacity -Cloud $cloud -JobGroup $job_id @update_params -ErrorAction Stop
            Set-SCCloud -Cloud $cloud -JobGroup $job_id -ErrorAction Stop
        }
    }

    $final_capacity = Get-SCCloudCapacity -Cloud $cloud
    $module.Result.changed = $changed
    $module.Result.capacity = @{
        cpu_count = $final_capacity.CPUCount
        memory_mb = $final_capacity.Memory
        storage_gb = $final_capacity.Storage
        vm_count = $final_capacity.VMCount
    }
}
catch {
    $module.FailJson("Failed to update cloud capacity: $($_.Exception.Message)", $_)
}

$module.ExitJson()
