#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

#AnsibleRequires -CSharpUtil Ansible.Basic

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = "str" }
        host_group = @{ type = "str" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$host_group = $module.Params.host_group

try {
    # Import SCVMM module using utility
    Import-SCVMMModule -Module $module

    $cmdParams = @{
        ErrorAction = "Stop"
    }

    if ($name) {
        $cmdParams.Name = $name
    }

    if ($host_group) {
        $hg = Get-SCVMHostGroup -Name $host_group -ErrorAction SilentlyContinue
        if ($null -eq $hg) {
            $module.FailJson("Host group '$host_group' not found.")
        }
        $cmdParams.VMHostGroup = $hg
    }

    $hosts = Get-SCVMHost @cmdParams

    $results = @()
    if ($hosts) {
        # Normalize to array if single object returned
        if (-not ($hosts -is [array])) {
            $hosts = @($hosts)
        }
        foreach ($h in $hosts) {
            $results += Get-SCVMMHostInfo -VMHost $h
        }
    }

    $module.Result.hosts = $results
}
catch {
    $module.FailJson("Failed to gather SCVMM host information: $($_.Exception.Message)", $_)
}

$module.ExitJson()
