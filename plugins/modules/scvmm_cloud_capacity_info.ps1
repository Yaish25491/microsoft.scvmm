#!powershell
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_infra

#AnsibleRequires -CSharpUtil Ansible.Basic

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        cloud = @{ type = "str"; required = $true }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

try {
    # Import SCVMM module using utility
    Import-SCVMMModule -Module $module

    $cloud = Get-SCCloud -Name $module.Params.cloud -ErrorAction Stop
    $capacity = Get-SCCloudCapacity -Cloud $cloud -ErrorAction Stop

    $module.Result.cloud_capacity = @{
        cpu_count = $capacity.CPUCount
        memory_mb = $capacity.MemoryMB
        storage_gb = $capacity.StorageGB
        vm_count = $capacity.VMCount
        custom_quota_points = $capacity.CustomQuotaPoints
        use_maximum_cloud_capacity = $capacity.UseMaximumCloudCapacity
    }
}
catch {
    $module.FailJson("Failed to gather SCVMM cloud capacity information: $($_.Exception.Message)", $_)
}

$module.ExitJson()
