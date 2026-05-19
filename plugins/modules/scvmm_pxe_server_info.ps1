#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm_compliance

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
    $pxe_servers = Get-SCPXEServer @get_params -ErrorAction Stop
}
catch {
    $module.FailJson("Failed to gather PXE server information: $($_.Exception.Message)")
}

$module.Result.pxe_servers = @()
if ($null -ne $pxe_servers) {
    foreach ($server in $pxe_servers) {
        $module.Result.pxe_servers += Get-SCPXEServerInfo -PXEServer $server
    }
}

$module.ExitJson()
