#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm_compute

#AnsibleRequires -CSharpUtil Ansible.Basic

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = "str" }
        host = @{ type = "str" }
        cloud = @{ type = "str" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$host_param = $module.Params.host
$cloud = $module.Params.cloud

$module.Result.vms = @()

try {
    # Import SCVMM module using utility
    Import-SCVMMModule -Module $module

    $cmdletArgs = @{
        ErrorAction = "Stop"
    }

    if ($name) {
        $cmdletArgs.Name = $name
    }

    # In SCVMM, we can use -VMHost to filter by host
    if ($host_param) {
        $vmHost = Get-SCVMHost -ComputerName $host_param -ErrorAction Stop
        if ($vmHost) {
            $cmdletArgs.VMHost = $vmHost
        }
    }

    # In SCVMM, we can use -Cloud to filter by cloud
    if ($cloud) {
        $scCloud = Get-SCCloud -Name $cloud -ErrorAction Stop
        if ($scCloud) {
            $cmdletArgs.Cloud = $scCloud
        }
    }

    $vms = Get-SCVirtualMachine @cmdletArgs

    if ($vms) {
        # Ensure we always process an array even if a single item is returned
        $vmsArray = @($vms)
        foreach ($vm in $vmsArray) {
            $module.Result.vms += Get-SCVMMVMInfo -VM $vm
        }
    }
}
catch {
    $module.FailJson("Failed to gather VM info: $($_.Exception.Message)", $_)
}

$module.ExitJson()
