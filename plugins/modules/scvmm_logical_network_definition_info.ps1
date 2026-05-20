#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_network

$spec = @{
    options = @{
        name = @{ type = "str" }
        logical_network = @{ type = "str" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$logical_network_name = $module.Params.logical_network

$params = @{}
if ($null -ne $name) { $params["Name"] = $name }

if ($null -ne $logical_network_name) {
    $logical_network = Get-SCLogicalNetwork -Name $logical_network_name -ErrorAction SilentlyContinue
    if ($null -eq $logical_network) {
        $module.ExitJson(@{ logical_network_definitions = @() })
    }
    $params["LogicalNetwork"] = $logical_network
}

try {
    $definitions = Get-SCLogicalNetworkDefinition @params -ErrorAction Stop
    $result = $definitions | ForEach-Object { Get-SCVMMLogicalNetworkDefinitionInfo -LogicalNetworkDefinition $_ }
    $module.ExitJson(@{ logical_network_definitions = $result })
}
catch {
    $module.FailJson("Failed to gather logical network definition information: $($_.Exception.Message)", $_)
}
