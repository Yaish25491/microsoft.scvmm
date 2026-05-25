#!powershell
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_library

$ErrorActionPreference = "Stop"

function Get-SCVMMScriptInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Script object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a Script object and returns a standardized hashtable.
    .PARAMETER Script
    The SCScript object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Script
    )

    $info = @{
        name = $Script.Name
        id = $Script.ID.Guid
        description = $Script.Description
        family_name = $Script.FamilyName
        release = $Script.Release
        library_server = if ($Script.LibraryServer) { $Script.LibraryServer.Name } else { $null }
        share_path = $Script.SharePath
        is_equivalent = $Script.IsEquivalent
        added_time = if ($Script.AddedTime) { $Script.AddedTime.ToString('yyyy-MM-ddTHH:mm:ssZ') } else { $null }
        modified_time = if ($Script.ModifiedTime) { $Script.ModifiedTime.ToString('yyyy-MM-ddTHH:mm:ssZ') } else { $null }
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

    $scripts = Get-SCScript @params -ErrorAction Stop

    $results = @()
    foreach ($script in $scripts) {
        $results += Get-SCVMMScriptInfo -Script $script
    }

    $module.Result.scripts = $results
}
catch {
    $global:Error.Clear()
    $module.FailJson("Failed to gather script info: $($_.Exception.Message)", $_)
}

$module.ExitJson()
