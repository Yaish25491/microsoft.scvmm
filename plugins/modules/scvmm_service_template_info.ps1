#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_service

function Get-SCVMMServiceTemplateInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Service Template object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a ServiceTemplate object and returns a standardized hashtable.
    .PARAMETER ServiceTemplate
    The ServiceTemplate object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$ServiceTemplate
    )

    $info = @{
        name = $ServiceTemplate.Name
        id = $ServiceTemplate.ID.Guid
        description = $ServiceTemplate.Description
        release = $ServiceTemplate.Release
        owner = $ServiceTemplate.Owner
        service_priority = if ($ServiceTemplate.ServicePriority) { $ServiceTemplate.ServicePriority.ToString() } else { $null }
        user_role = if ($ServiceTemplate.UserRole) { $ServiceTemplate.UserRole.Name } else { $null }
        is_published = $ServiceTemplate.Published
    }

    return $info
}

$spec = @{
    options = @{
        name = @{ type = 'str' }
        release = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$release = $module.Params.release

Import-SCVMMModule -Module $module

$getParams = @{}
if ($name) {
    $getParams.Name = $name
}
if ($release) {
    $getParams.Release = $release
}

try {
    $templates = @(Get-SCServiceTemplate @getParams -ErrorAction Stop)
}
catch {
    $global:Error.Clear()
    $module.FailJson("Failed to get service templates: $($_.Exception.Message)")
}

$result = @()
foreach ($template in $templates) {
    $result += Get-SCVMMServiceTemplateInfo -ServiceTemplate $template
}

$module.Result.service_templates = $result
$module.ExitJson()
