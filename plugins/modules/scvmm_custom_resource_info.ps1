#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module Ansible.ModuleUtils.SCVMM

$ErrorActionPreference = 'Stop'

$spec = @{
    options = @{
        name = @{ type = 'str' }
        id = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$id = $module.Params.id

try {
    $params = @{}
    if ($id) {
        $params.ID = $id
    }
    elseif ($name) {
        $params.Name = $name
    }

    $resources = Get-SCCustomResource @params -ErrorAction Stop

    $resourceList = @()
    if ($resources) {
        foreach ($resource in $resources) {
            $resourceList += Get-SCVMMCustomResourceInfo -CustomResource $resource
        }
    }

    $module.Result.scvmm_custom_resources = $resourceList
}
catch {
    $global:Error.Clear()
    $module.FailJson("Failed to gather custom resource info: $($_.Exception.Message)")
}

$module.ExitJson()
