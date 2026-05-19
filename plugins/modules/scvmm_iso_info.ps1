#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm_library

$ErrorActionPreference = "Stop"

function Get-SCVMMISOInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM ISO object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from an ISO object and returns a standardized hashtable.
    .PARAMETER ISO
    The SCISO object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$ISO
    )

    $info = @{
        name = $ISO.Name
        id = $ISO.ID.Guid
        description = $ISO.Description
        family_name = $ISO.FamilyName
        release = $ISO.Release
        library_server = if ($ISO.LibraryServer) { $ISO.LibraryServer.Name } else { $null }
        share_path = $ISO.SharePath
        size = $ISO.Size
        is_equivalent = $ISO.IsEquivalent
        added_time = if ($ISO.AddedTime) { $ISO.AddedTime.ToString('yyyy-MM-ddTHH:mm:ssZ') } else { $null }
        modified_time = if ($ISO.ModifiedTime) { $ISO.ModifiedTime.ToString('yyyy-MM-ddTHH:mm:ssZ') } else { $null }
    }

    return $info
}

$spec = @{
    options = @{
        name = @{ type = 'str' }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$vmm_server = $module.Params.vmm_server

try {
    $params = @{}
    if ($name) { $params.Name = $name }
    if ($vmm_server) { $params.VMMServer = $vmm_server }

    $isos = Get-SCISO @params -ErrorAction Stop

    $results = @()
    foreach ($iso in $isos) {
        $results += Get-SCVMMISOInfo -ISO $iso
    }

    $module.Result.isos = $results
}
catch {
    $global:Error.Clear()
    $module.FailJson("Failed to gather ISO info: $($_.Exception.Message)", $_)
}

$module.ExitJson()
