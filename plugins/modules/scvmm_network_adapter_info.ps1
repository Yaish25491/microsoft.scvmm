#!powershell
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_network

$params = @{
    vm_name = @{ type = 'str' }
    vm_template_name = @{ type = 'str' }
    hardware_profile_name = @{ type = 'str' }
    id = @{ type = 'str' }
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $params)

Import-SCVMMModule -Module $module

$vm_name = $module.Params.vm_name
$vm_template_name = $module.Params.vm_template_name
$hardware_profile_name = $module.Params.hardware_profile_name
$id = $module.Params.id

$adapters = @()

try {
    if ($null -ne $id) {
        $sc_adapters = Get-SCVirtualNetworkAdapter -ID $id -ErrorAction Stop
    }
    elseif ($null -ne $vm_name) {
        $vm = Get-SCVirtualMachine -Name $vm_name -ErrorAction Stop
        $sc_adapters = Get-SCVirtualNetworkAdapter -VM $vm -ErrorAction Stop
    }
    elseif ($null -ne $vm_template_name) {
        $template = Get-SCVMTemplate -Name $vm_template_name -ErrorAction Stop
        $sc_adapters = Get-SCVirtualNetworkAdapter -VMTemplate $template -ErrorAction Stop
    }
    elseif ($null -ne $hardware_profile_name) {
        $hw_profile = Get-SCHardwareProfile | Where-Object { $_.Name -eq $hardware_profile_name }
        if ($null -eq $hw_profile) {
            $module.FailJson("Hardware Profile '$hardware_profile_name' not found.")
        }
        $sc_adapters = Get-SCVirtualNetworkAdapter -HardwareProfile $hw_profile -ErrorAction Stop
    }
    else {
        $sc_adapters = Get-SCVirtualNetworkAdapter -All -ErrorAction Stop
    }

    foreach ($adapter in $sc_adapters) {
        $adapters += Get-SCVMMVirtualNetworkAdapterInfo -Adapter $adapter
    }
}
catch {
    $module.FailJson("Failed to gather virtual network adapter information: $($_.Exception.Message)", $_)
}

$module.Result.virtual_network_adapters = $adapters
$module.ExitJson()
