#!powershell
# Copyright: (c) 2026, Ansible Project
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy

$ErrorActionPreference = 'Stop'

function Get-SCVMMLibraryResourceInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Library Resource object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a LibraryResource object and returns a standardized hashtable.
    .PARAMETER LibraryResource
    The SCLibraryResource object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$LibraryResource
    )

    $info = @{
        name = $LibraryResource.Name
        id = $LibraryResource.ID.Guid
        description = $LibraryResource.Description
        library_server = if ($LibraryResource.LibraryServer) { $LibraryResource.LibraryServer.Name } else { $null }
        share_path = $LibraryResource.SharePath
    }

    return $info
}

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        state = @{ type = 'str'; default = 'present'; choices = @('absent', 'present') }
        description = @{ type = 'str' }
        library_server = @{ type = 'str' }
        vmm_server = @{ type = 'str' }
        vmm_username = @{ type = 'str' }
        vmm_password = @{ type = 'str'; no_log = $true }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$state = $module.Params.state
$description = $module.Params.description
$library_server = $module.Params.library_server

Import-SCVMMModule -Module $module

try {
    $getParams = @{ ErrorAction = "SilentlyContinue" }
    if ($name) {
        $getParams.Name = $name
    }
    if ($module.Params.vmm_server) {
        $getParams.VMMServer = $module.Params.vmm_server
    }

    $resources = Get-SCLibraryResource @getParams

    if ($resources -is [array]) {
        if ($library_server) {
            $resources = $resources | Where-Object { $_.LibraryServer.Name -eq $library_server }
        }
    }

    if ($resources -is [array]) {
        if ($resources.Count -gt 1) {
            $module.FailJson("Multiple library resources found with the name '$name'. Please provide a library_server to be more specific.")
        }
        $resource = $resources[0]
    }
    else {
        $resource = $resources
        if ($resource -and $library_server -and $resource.LibraryServer.Name -ne $library_server) {
            $resource = $null
        }
    }

    $module.Result.changed = $false

    if ($state -eq 'present') {
        if (-not $resource) {
            $module.FailJson("Library resource '$name' does not exist. This module only updates existing resources.")
        }

        $updateParams = @{
            LibraryResource = $resource
            ErrorAction = "Stop"
        }
        $needsUpdate = $false

        if ($null -ne $description -and $resource.Description -ne $description) {
            $updateParams.Description = $description
            $needsUpdate = $true
        }

        if ($needsUpdate) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                $resource = Set-SCLibraryResource @updateParams
            }
        }
    }
    elseif ($state -eq 'absent') {
        if ($resource) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                Remove-SCLibraryResource -LibraryResource $resource -ErrorAction Stop
                $resource = $null
            }
        }
    }

    if ($resource) {
        $module.Result.library_resource = Get-SCVMMLibraryResourceInfo -LibraryResource $resource
    }
    $module.ExitJson()
}
catch {
    $global:Error.Clear()
    $err = $_.Exception.Message
    $module.FailJson("Failed to manage library resource: $err")
}
