#!powershell
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_infra

#AnsibleRequires -CSharpUtil Ansible.Basic

$ErrorActionPreference = "Stop"

function Get-SCVMMHostInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM VM Host object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a Host object and returns a standardized hashtable.
    .PARAMETER VMHost
    The SCVMHost object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$VMHost
    )

    $info = @{
        name = $VMHost.Name
        id = $VMHost.ID.Guid
        description = $VMHost.Description
        host_group = if ($VMHost.VMHostGroup) { $VMHost.VMHostGroup.Name } else { $null }
        virtualization_platform = $VMHost.VirtualizationPlatform.ToString()
        operating_system = if ($VMHost.OperatingSystem) { $VMHost.OperatingSystem.Name } else { $null }
        overall_state = $VMHost.OverallState.ToString()
        total_memory = $VMHost.TotalMemory
        available_memory = $VMHost.AvailableMemory
        cpu_count = $VMHost.CPUCount
        cpu_utilization = $VMHost.CPUUtilization
        is_connected = $VMHost.IsConnected
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
