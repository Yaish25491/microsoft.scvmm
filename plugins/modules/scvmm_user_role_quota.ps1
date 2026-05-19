#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm_rbac

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        user_role = @{ type = 'str'; required = $true }
        cloud = @{ type = 'str'; required = $true }
        quota_per_user = @{ type = 'bool'; default = $false }
        use_default_quota = @{ type = 'bool'; default = $false }
        cpu_count = @{ type = 'int' }
        memory_mb = @{ type = 'int' }
        storage_gb = @{ type = 'int' }
        vm_count = @{ type = 'int' }
        custom_quota = @{ type = 'int' }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$user_role_name = $module.Params.user_role
$cloud_name = $module.Params.cloud
$quota_per_user = $module.Params.quota_per_user
$use_default_quota = $module.Params.use_default_quota
$cpu_count = $module.Params.cpu_count
$memory_mb = $module.Params.memory_mb
$storage_gb = $module.Params.storage_gb
$vm_count = $module.Params.vm_count
$custom_quota = $module.Params.custom_quota
$vmm_server = $module.Params.vmm_server

try {
    $roleParams = @{ Name = $user_role_name; ErrorAction = "SilentlyContinue" }
    if ($vmm_server) { $roleParams.VMMServer = $vmm_server }
    $role = Get-SCUserRole @roleParams

    if (-not $role) { $module.FailJson("User Role '$user_role_name' not found.") }

    $cloudParams = @{ Name = $cloud_name; ErrorAction = "SilentlyContinue" }
    if ($vmm_server) { $cloudParams.VMMServer = $vmm_server }
    $cloud = Get-SCCloud @cloudParams

    if (-not $cloud) { $module.FailJson("Cloud '$cloud_name' not found.") }

    $quotaParams = @{
        UserRole = $role
        Cloud = $cloud
        ErrorAction = "SilentlyContinue"
    }

    if ($quota_per_user) {
        $quotaParams.QuotaPerUser = $true
    }

    $current_quota = Get-SCUserRoleQuota @quotaParams

    if (-not $current_quota) {
        $module.FailJson("No quota configuration found for this User Role and Cloud combination.")
    }

    $changed = $false
    $updateParams = @{ UserRoleQuota = $current_quota; ErrorAction = "Stop" }

    if ($use_default_quota) {
        if (-not $current_quota.UseDefaultQuota) {
            $updateParams.UseDefaultQuota = $true
            $changed = $true
        }
    }
    else {
        if ($current_quota.UseDefaultQuota) {
            $updateParams.UseDefaultQuota = $false
            $changed = $true
        }

        if ($null -ne $cpu_count -and $current_quota.CPUCount -ne $cpu_count) { $updateParams.CPUCount = $cpu_count; $changed = $true }
        if ($null -ne $memory_mb -and $current_quota.MemoryMB -ne $memory_mb) { $updateParams.MemoryMB = $memory_mb; $changed = $true }
        if ($null -ne $storage_gb -and $current_quota.StorageGB -ne $storage_gb) { $updateParams.StorageGB = $storage_gb; $changed = $true }
        if ($null -ne $vm_count -and $current_quota.VMCount -ne $vm_count) { $updateParams.VMCount = $vm_count; $changed = $true }
        if ($null -ne $custom_quota -and $current_quota.CustomQuota -ne $custom_quota) { $updateParams.CustomQuota = $custom_quota; $changed = $true }
    }

    if ($changed) {
        $module.Result.changed = $true
        if (-not $module.CheckMode) {
            Set-SCUserRoleQuota @updateParams | Out-Null
            $current_quota = Get-SCUserRoleQuota @quotaParams
        }
    }

    $module.Result.user_role_quota = Get-SCVMMUserRoleQuotaInfo -UserRoleQuota $current_quota
}
catch {
    $module.FailJson("Failed to manage user role quota: $($_.Exception.Message)", $_)
}

$module.ExitJson()
