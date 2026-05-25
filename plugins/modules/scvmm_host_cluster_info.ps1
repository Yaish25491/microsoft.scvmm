#!powershell
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_infra

#AnsibleRequires -CSharpUtil Ansible.Basic

$ErrorActionPreference = "Stop"

function Get-SCVMMHostClusterInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Host Cluster object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a VMHostCluster object and returns a standardized hashtable.
    .PARAMETER Cluster
    The VMHostCluster object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Cluster
    )

    $info = @{
        name = $Cluster.Name
        id = $Cluster.ID.Guid
        cluster_reserve = $Cluster.ClusterReserve
        is_over_committed = $Cluster.IsOverCommitted
        nodes = $Cluster.Nodes | ForEach-Object { $_.Name }
        vm_host_group = if ($Cluster.VMHostGroup) { $Cluster.VMHostGroup.Name } else { $null }
        vm_paths = $Cluster.VMPaths
        remote_connect_enabled = $Cluster.RemoteConnectEnabled
        remote_connect_port = $Cluster.RemoteConnectPort
        virtualization_platform = if ($Cluster.VirtualizationPlatform) { $Cluster.VirtualizationPlatform.ToString() } else { $null }
    }

    return $info
}

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
