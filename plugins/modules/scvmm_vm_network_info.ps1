#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_network

$params = @{
    name = @{ type = 'str' }
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $params)

Import-SCVMMModule -Module $module

$name = $module.Params.name

$networks = @()

try {
    if ($null -ne $name) {
        $vm_networks = Get-SCVMNetwork -Name $name -ErrorAction Stop
    }
    else {
        $vm_networks = Get-SCVMNetwork -ErrorAction Stop
    }

    foreach ($vn in $vm_networks) {
        $networks += Get-SCVMMVMNetworkInfo -VMNetwork $vn
    }
}
catch {
    $module.FailJson("Failed to gather VM network information: $($_.Exception.Message)", $_)
}

$module.Result.vm_networks = $networks
$module.ExitJson()
