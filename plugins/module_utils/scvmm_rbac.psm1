# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

function Get-SCVMMUserRoleQuotaInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM User Role Quota object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a UserRoleQuota object and returns a standardized hashtable.
    .PARAMETER Quota
    The UserRoleQuota object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Quota
    )

    $info = @{
        id = $Quota.ID.Guid
        cloud = if ($Quota.Cloud) { $Quota.Cloud.Name } else { $null }
        user_role = if ($Quota.UserRole) { $Quota.UserRole.Name } else { $null }
        quota_per_user = $Quota.QuotaPerUser
        cpu_count = $Quota.CPUCount
        use_cpu_count_maximum = $Quota.UseCPUCountMaximum
        memory_mb = $Quota.MemoryMB
        use_memory_mb_maximum = $Quota.UseMemoryMBMaximum
        storage_gb = $Quota.StorageGB
        use_storage_gb_maximum = $Quota.UseStorageGBMaximum
        vm_count = $Quota.VMCount
        use_vm_count_maximum = $Quota.UseVMCountMaximum
        custom_quota_count = $Quota.CustomQuotaCount
        use_custom_quota_count_maximum = $Quota.UseCustomQuotaCountMaximum
    }

    return $info
}

function Get-SCVMMRunAsAccountInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Run As Account object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a RunAsAccount object and returns a standardized hashtable.
    .PARAMETER RunAsAccount
    The RunAsAccount object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$RunAsAccount
    )

    $info = @{
        name = $RunAsAccount.Name
        id = $RunAsAccount.ID.Guid
        description = $RunAsAccount.Description
        user_name = $RunAsAccount.UserName
        is_enabled = $RunAsAccount.IsEnabled
        owner = $RunAsAccount.Owner
    }

    return $info
}

function Get-SCVMMUserRoleInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM User Role object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a UserRole object and returns a standardized hashtable.
    .PARAMETER UserRole
    The UserRole object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$UserRole
    )

    $info = @{
        name = $UserRole.Name
        id = $UserRole.ID.Guid
        description = $UserRole.Description
        profile = if ($UserRole.Profile) { $UserRole.Profile.ToString() } else { $null }
        members = $UserRole.Members
        parent_user_role = if ($UserRole.ParentUserRole) { $UserRole.ParentUserRole.Name } else { $null }
    }

    return $info
}

Export-ModuleMember -Function 'Get-SCVMMUserRoleQuotaInfo', 'Get-SCVMMRunAsAccountInfo', 'Get-SCVMMUserRoleInfo'
