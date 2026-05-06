#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

$params = @{
    name = @{ type = 'str' }
    vm_network = @{ type = 'str' }
}

$module = [Ansible.ModuleUtils.Legacy.AnsibleModule]::Create($args, $params)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$vm_network_name = $module.Params.vm_network

$get_params = @{}
if ($null -ne $name) { $get_params.Name = $name }

if ($null -ne $vm_network_name) {
    $vm_network = Get-SCVMNetwork -Name $vm_network_name -ErrorAction SilentlyContinue
    if ($null -eq $vm_network) {
        $module.FailJson("VM Network '$vm_network_name' not found.")
    }
    $get_params.VMNetwork = $vm_network
}

try {
    $subnets = Get-SCVMSubnet @get_params -ErrorAction Stop
}
catch {
    $module.FailJson("Failed to gather VM Subnet information: $($_.Exception.Message)", $_)
}

$module.Result.vm_subnets = @()
foreach ($subnet in $subnets) {
    $module.Result.vm_subnets += Get-SCVMMVMSubnetInfo -VMSubnet $subnet
}

$module.ExitJson()
