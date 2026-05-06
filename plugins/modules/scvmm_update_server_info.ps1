#!powershell
# Copyright: (c) 2026, Hen Yaish
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

$params = Parse-Args $args -operators $true

$spec = @{
    computer_name = @{ type = "str" }
}

$module = [Ansible.Basic.AnsibleModule]::Create($params, $spec)

Import-SCVMMModule -Module $module

$computer_name = $module.Params.computer_name

$get_params = @{}
if ($null -ne $computer_name) {
    $get_params.ComputerName = $computer_name
}

try {
    $update_servers = Get-SCUpdateServer @get_params -ErrorAction Stop
}
catch {
    $module.FailJson("Failed to gather update server information: $($_.Exception.Message)")
}

$module.Result.update_servers = @()
if ($null -ne $update_servers) {
    foreach ($server in $update_servers) {
        $module.Result.update_servers += Get-SCUpdateServerInfo -UpdateServer $server
    }
}

$module.ExitJson()
