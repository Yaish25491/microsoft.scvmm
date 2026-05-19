#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm_network

#AnsibleRequires -CSharpUtil Ansible.Basic

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = "str" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name

$module.Result.mac_address_pools = @()

try {
    # Import SCVMM module using utility
    Import-SCVMMModule -Module $module

    $cmdletArgs = @{
        ErrorAction = "Stop"
    }

    if ($name) {
        $cmdletArgs.Name = $name
    }

    $pools = Get-SCMACAddressPool @cmdletArgs

    if ($pools) {
        # Ensure we always process an array even if a single item is returned
        $poolsArray = @($pools)
        foreach ($pool in $poolsArray) {
            $module.Result.mac_address_pools += Get-SCVMMMACAddressPoolInfo -MACAddressPool $pool
        }
    }
}
catch {
    $module.FailJson("Failed to gather MAC address pool info: $($_.Exception.Message)", $_)
}

$module.ExitJson()
