#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module VirtualMachineManager
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
        if (-not $hg) {
            $module.FailJson("Host Group '$host_group' not found.")
        }
        $cmdParams.VMHostGroup = $hg
    }

    $clusters = Get-SCVMHostCluster @cmdParams

    $results = @()
    if ($clusters) {
        # Normalize to array if single object returned
        if (-not ($clusters -is [array])) {
            $clusters = @($clusters)
        }
        foreach ($cluster in $clusters) {
            $results += Get-SCVMMHostClusterInfo -Cluster $cluster
        }
    }

    $module.Result.host_clusters = $results
}
catch {
    $module.FailJson("Failed to gather SCVMM host cluster information: $($_.Exception.Message)", $_)
}

$module.ExitJson()
