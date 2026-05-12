#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        vmm_server = @{ type = 'str' }
        vmm_server_object = @{ type = 'bool'; default = $false }
        vm_host = @{ type = 'str' }
        host_cluster = @{ type = 'str' }
        vm = @{ type = 'str' }
        baseline_name = @{ type = 'str' }
    }
    required_one_of = @(
        @('vmm_server_object', 'vm_host', 'host_cluster', 'vm')
    )
    mutually_exclusive = @(
        @('vmm_server_object', 'vm_host', 'host_cluster', 'vm')
    )
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$vmm_server = $module.Params.vmm_server
$vmm_server_object = $module.Params.vmm_server_object
$vm_host = $module.Params.vm_host
$host_cluster = $module.Params.host_cluster
$vm_name = $module.Params.vm
$baseline_name = $module.Params.baseline_name

try {
    Import-SCVMMModule -Module $module

    $getParams = @{
        ErrorAction = "Stop"
    }
    if ($vmm_server) {
        $getParams.VMMServer = $vmm_server
    }

    $targetObjects = @()

    if ($vmm_server_object) {
        $serverObj = Get-SCVMMServer -ComputerName $vmm_server -ErrorAction Stop
        if (-not $serverObj) {
            $module.FailJson("Failed to find VMM server '$vmm_server'.")
        }
        $targetObjects += $serverObj
    }
    elseif ($vm_host) {
        $hostObj = Get-SCVMHost -ComputerName $vm_host @getParams
        if (-not $hostObj) {
            $module.FailJson("Failed to find VM Host '$vm_host'.")
        }
        $targetObjects += $hostObj
    }
    elseif ($host_cluster) {
        $clusterObj = Get-SCVMHostCluster -Name $host_cluster @getParams
        if (-not $clusterObj) {
            $module.FailJson("Failed to find Host Cluster '$host_cluster'.")
        }
        $targetObjects += $clusterObj
    }
    elseif ($vm_name) {
        $scvm = Get-SCVirtualMachine -Name $vm_name @getParams
        if (-not $scvm) {
            $module.FailJson("Failed to find Virtual Machine '$vm_name'.")
        }
        if ($scvm -is [array]) {
            $module.FailJson("Found multiple Virtual Machines with name '$vm_name'.")
        }
        $targetObjects += $scvm
    }

    $complianceInfoList = @()

    foreach ($target in $targetObjects) {
        $statusCmdParams = @{
            ErrorAction = "Stop"
        }

        # Using pipeline because Get-SCComplianceStatus takes different types
        $statusObjs = $target | Get-SCComplianceStatus @statusCmdParams -ErrorAction SilentlyContinue

        if ($statusObjs) {
            foreach ($statusObj in $statusObjs) {
                # Filter by baseline_name if provided
                if ($baseline_name -and $statusObj.Baseline -and $statusObj.Baseline.Name -ne $baseline_name) {
                    continue
                }
                $info = Get-SCVMMComplianceStatusInfo -ComplianceStatus $statusObj
                $complianceInfoList += $info
            }
        }
    }

    $module.Result.compliance_status = $complianceInfoList
}
catch {
    $global:Error.Clear()
    $module.FailJson("An error occurred: $($_.Exception.Message)", $_)
}

$module.ExitJson()
