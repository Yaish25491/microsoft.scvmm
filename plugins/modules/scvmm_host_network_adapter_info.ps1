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
        vm_host = @{ type = "str"; required = $true }
        name = @{ type = "str" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$vm_host_name = $module.Params.vm_host
$name = $module.Params.name

try {
    Import-SCVMMModule -Module $module

    $vm_host = Get-SCVMHost -Name $vm_host_name -ErrorAction SilentlyContinue
    if ($null -eq $vm_host) {
        $module.FailJson("VM Host '$vm_host_name' not found.")
    }

    $cmdParams = @{
        VMHost = $vm_host
        ErrorAction = "Stop"
    }

    if ($name) {
        $cmdParams.Name = $name
    }

    $adapters = Get-SCVMHostNetworkAdapter @cmdParams

    $results = @()
    if ($adapters) {
        if (-not ($adapters -is [array])) {
            $adapters = @($adapters)
        }
        foreach ($a in $adapters) {
            $results += Get-SCVMMHostNetworkAdapterInfo -Adapter $a
        }
    }

    $module.Result.host_network_adapters = $results
}
catch {
    $module.FailJson("Failed to gather SCVMM host network adapter information: $($_.Exception.Message)", $_)
}

$module.ExitJson()
