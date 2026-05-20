#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_network

$spec = @{
    name = @{ type = "str" }
}

$module = [Ansible.ModuleUtils.Legacy.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name

$get_params = @{}
if ($name) {
    $get_params.Name = $name
}

try {
    $logical_switches = Get-SCLogicalSwitch @get_params -ErrorAction Stop
}
catch {
    $module.FailJson("Failed to gather logical switch information: $($_.Exception.Message)", $_)
}

$info_list = @()
foreach ($ls in $logical_switches) {
    $info_list += Get-SCVMMLogicalSwitchInfo -LogicalSwitch $ls
}

$module.Result.scvmm_logical_switches = $info_list
$module.ExitJson()
