#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_storage

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = "str" }
        vmm_server = @{ type = "str" }
    }
    supports_check_mode = $true
}

$module = [Ansible.ModuleUtils.Legacy.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$vmm_server = $module.Params.vmm_server

$module.Result.virtual_hard_disks = @()

try {
    # Import SCVMM module using utility
    Import-SCVMMModule -Module $module

    $cmdletArgs = @{
        ErrorAction = "Stop"
    }

    if ($vmm_server) {
        $cmdletArgs.VMMServer = $vmm_server
    }

    if ($name) {
        $cmdletArgs.Name = $name
    }

    $vhds = Get-SCVirtualHardDisk @cmdletArgs

    if ($vhds) {
        # Ensure we always process an array even if a single item is returned
        $vhdsArray = @($vhds)
        foreach ($vhd in $vhdsArray) {
            $module.Result.virtual_hard_disks += Get-SCVMMVirtualHardDiskInfo -VirtualHardDisk $vhd
        }
    }
}
catch {
    $module.FailJson("Failed to gather Virtual Hard Disk info: $($_.Exception.Message)", $_)
}

$module.ExitJson()
