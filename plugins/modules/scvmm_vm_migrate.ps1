#!powershell
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_compute

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        vm_host = @{ type = 'str' }
        vm_host_group = @{ type = 'str' }
        vm_cluster = @{ type = 'str' }
        path = @{ type = 'str' }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$vm_host = $module.Params.vm_host
$vm_host_group = $module.Params.vm_host_group
$vm_cluster = $module.Params.vm_cluster
$path = $module.Params.path
$vmm_server = $module.Params.vmm_server

$module.Result.changed = $false

try {
    # Import SCVMM module using utility
    Import-SCVMMModule -Module $module

    $getParams = @{}
    if ($vmm_server) { $getParams.VMMServer = $vmm_server }

    # Get VM
    $vmGetParams = $getParams.Clone()
    $vmGetParams.Name = $name
    $vm = Get-SCVirtualMachine @vmGetParams -ErrorAction SilentlyContinue

    if (-not $vm) {
        $module.FailJson("Virtual machine '$name' not found.")
    }
    if ($vm -is [array] -and $vm.Count -gt 1) {
        $module.FailJson("Multiple virtual machines found with the name '$name'. Please be more specific.")
    }

    # Determine Target Host
    $targetHost = $null
    if ($vm_host) {
        $hostGetParams = $getParams.Clone()
        $hostGetParams.ComputerName = $vm_host
        $targetHost = Get-SCVMHost @hostGetParams -ErrorAction SilentlyContinue
        if (-not $targetHost) {
            $module.FailJson("Target host '$vm_host' not found.")
        }
    }
    elseif ($vm_host_group) {
        $hgGetParams = $getParams.Clone()
        $hgGetParams.Name = $vm_host_group
        $hg = Get-SCVMHostGroup @hgGetParams -ErrorAction SilentlyContinue
        if (-not $hg) {
            $module.FailJson("Host group '$vm_host_group' not found.")
        }
        $rating = Get-SCVMHostRating -VM $vm -VMHostGroup $hg | Sort-Object Rating -Descending | Select-Object -First 1
        if (-not $rating -or -not $rating.VMHost) {
            $module.FailJson("No suitable host found in host group '$vm_host_group'.")
        }
        $targetHost = $rating.VMHost
    }
    elseif ($vm_cluster) {
        $clusterGetParams = $getParams.Clone()
        $clusterGetParams.Name = $vm_cluster
        $cluster = Get-SCVMCluster @clusterGetParams -ErrorAction SilentlyContinue
        if (-not $cluster) {
            $module.FailJson("Cluster '$vm_cluster' not found.")
        }
        $rating = Get-SCVMHostRating -VM $vm -VMHostCluster $cluster | Sort-Object Rating -Descending | Select-Object -First 1
        if (-not $rating -or -not $rating.VMHost) {
            $module.FailJson("No suitable host found in cluster '$vm_cluster'.")
        }
        $targetHost = $rating.VMHost
    }
    else {
        $module.FailJson("One of vm_host, vm_host_group, or vm_cluster must be specified.")
    }

    # Idempotency Check
    $currentHost = $vm.VMHost.Name
    $isAlreadyOnTarget = $false

    # Check if targetHost is part of the same cluster if target is a cluster
    if ($vm_cluster -and $vm.VMHost.VMHostCluster.Name -eq $vm_cluster) {
        $isAlreadyOnTarget = $true
    }
    elseif ($targetHost.Name -eq $currentHost) {
        # If targetHost is explicitly named and matches current host
        # Also check path if specified
        if ($null -ne $path) {
            # Simple path comparison, might need refinement depending on how VMM reports Path
            if ($vm.Path -eq $path -or $vm.Path.TrimEnd('\') -eq $path.TrimEnd('\')) {
                $isAlreadyOnTarget = $true
            }
        }
        else {
            $isAlreadyOnTarget = $true
        }
    }

    if (-not $isAlreadyOnTarget) {
        $module.Result.changed = $true

        $moveParams = @{
            VM = $vm
            VMHost = $targetHost
            ErrorAction = "Stop"
        }
        if ($path) { $moveParams.Path = $path }

        # If moving to a cluster node, we should ideally use -HighlyAvailable $true
        if ($vm_cluster -or $targetHost.VMHostCluster) {
            $moveParams.HighlyAvailable = $true
        }

        if (-not $module.CheckMode) {
            $vm = Move-SCVirtualMachine @moveParams
        }
    }

    $module.Result.vm = @{
        name = $vm.Name
        id = $vm.ID.Guid
        status = if ($vm.Status) { $vm.Status.ToString() } else { $vm.StatusString }
        vm_host = $vm.VMHost.Name
        path = $vm.Path
    }
}
catch {
    $module.FailJson("An error occurred: $($_.Exception.Message)", $_)
}

$module.ExitJson()
