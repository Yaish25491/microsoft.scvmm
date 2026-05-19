#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm_network

$spec = @{
    options = @{
        name = @{ type = "str" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name

$networks = @()

try {
    if ($null -ne $name) {
        $sc_networks = Get-SCLogicalNetwork -Name $name -ErrorAction SilentlyContinue
        if ($null -eq $sc_networks) {
            # Return empty list if specific network not found, consistent with info modules
        }
        else {
            foreach ($net in $sc_networks) {
                $networks += Get-SCVMMLogicalNetworkInfo -LogicalNetwork $net
            }
        }
    }
    else {
        $sc_networks = Get-SCLogicalNetwork
        foreach ($net in $sc_networks) {
            $networks += Get-SCVMMLogicalNetworkInfo -LogicalNetwork $net
        }
    }
}
catch {
    $module.FailJson("Failed to gather logical network information: $($_.Exception.Message)", $_)
}

$module.Result.logical_networks = $networks
$module.ExitJson()
