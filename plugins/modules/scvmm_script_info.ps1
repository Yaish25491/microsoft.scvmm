#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

$ErrorActionPreference = "Stop"

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
