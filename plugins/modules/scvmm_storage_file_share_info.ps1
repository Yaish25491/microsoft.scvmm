#!powershell
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_storage

function Get-SCVMMStorageFileShareInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Storage File Share object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a StorageFileShare object and returns a standardized hashtable.
    .PARAMETER StorageFileShare
    The StorageFileShare object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$StorageFileShare
    )

    $info = @{
        name = $StorageFileShare.Name
        id = $StorageFileShare.ID.Guid
        path = $StorageFileShare.Path
        description = $StorageFileShare.Description
        storage_classification = if ($StorageFileShare.StorageClassification) { $StorageFileShare.StorageClassification.Name } else { $null }
        capacity = $StorageFileShare.Capacity
        free_space = $StorageFileShare.FreeSpace
        is_available_for_placement = $StorageFileShare.IsAvailableForPlacement
        storage_file_server = if ($StorageFileShare.StorageFileServer) { $StorageFileShare.StorageFileServer.Name } else { $null }
        vm_host = if ($StorageFileShare.VMHost) { $StorageFileShare.VMHost.Name } else { $null }
        library_server = if ($StorageFileShare.LibraryServer) { $StorageFileShare.LibraryServer.Name } else { $null }
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

Import-SCVMMModule -Module $module

$name = $module.Params.name

try {
    if ($null -ne $name) {
        $shares = Get-SCStorageFileShare -Name $name -ErrorAction SilentlyContinue
    }
    else {
        $shares = Get-SCStorageFileShare -ErrorAction Stop
    }

    $shareInfo = @()
    foreach ($share in $shares) {
        $shareInfo += Get-SCVMMStorageFileShareInfo -StorageFileShare $share
    }

    $module.Result.storage_file_shares = $shareInfo
}
catch {
    $module.FailJson("Failed to gather storage file share information: $($_.Exception.Message)")
}

$module.ExitJson()
