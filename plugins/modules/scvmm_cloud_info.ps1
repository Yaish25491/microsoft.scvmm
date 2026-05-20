#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_infra

#AnsibleRequires -CSharpUtil Ansible.Basic

$ErrorActionPreference = "Stop"

function Get-SCVMMCloudInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Cloud object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a Cloud object and returns a standardized hashtable.
    .PARAMETER Cloud
    The SCCloud object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Cloud
    )

    $info = @{
        name = $Cloud.Name
        id = $Cloud.ID.Guid
        description = $Cloud.Description
        host_groups = $Cloud.VMHostGroups | ForEach-Object { $_.Name }
        read_only_library_shares = $Cloud.ReadOnlyLibraryShares | ForEach-Object { $_.Path }
        read_write_library_path = $Cloud.ReadWriteLibraryPath
        capability_profiles = $Cloud.CapabilityProfiles | ForEach-Object { $_.Name }
    }

    return $info
}

$spec = @{
    options = @{
        name = @{ type = "str" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name

try {
    # Import SCVMM module using utility
    Import-SCVMMModule -Module $module

    $cmdParams = @{
        ErrorAction = "Stop"
    }

    if ($name) {
        $cmdParams.Name = $name
    }

    $clouds = Get-SCCloud @cmdParams

    $results = @()
    if ($clouds) {
        # Normalize to array if single object returned
        if (-not ($clouds -is [array])) {
            $clouds = @($clouds)
        }
        foreach ($cloud in $clouds) {
            $results += Get-SCVMMCloudInfo -Cloud $cloud
        }
    }

    $module.Result.clouds = $results
}
catch {
    $module.FailJson("Failed to gather SCVMM private cloud information: $($_.Exception.Message)", $_)
}

$module.ExitJson()
