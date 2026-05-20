#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_infra

#AnsibleRequires -CSharpUtil Ansible.Basic

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = "str"; required = $true }
        state = @{ type = "str"; default = "present"; choices = @("absent", "present") }
        host_group = @{ type = "str" }
        run_as_account = @{ type = "str" }
        cluster_reserve = @{ type = "int" }
        vm_paths = @{ type = "str" }
        remote_connect_enabled = @{ type = "bool" }
        remote_connect_port = @{ type = "int" }
        description = @{ type = "str" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$state = $module.Params.state
$host_group_name = $module.Params.host_group
$run_as_account_name = $module.Params.run_as_account
$cluster_reserve = $module.Params.cluster_reserve
$vm_paths = $module.Params.vm_paths
$remote_connect_enabled = $module.Params.remote_connect_enabled
$remote_connect_port = $module.Params.remote_connect_port
$description = $module.Params.description

try {
    # Import SCVMM module using utility
    Import-SCVMMModule -Module $module

    $current_cluster = Get-SCVMHostCluster -Name $name -ErrorAction SilentlyContinue

    if ($state -eq "present") {
        if (-not $current_cluster) {
            # ADD CLUSTER
            if (-not $host_group_name) {
                $module.FailJson("host_group is required when adding a new host cluster.")
            }
            if (-not $run_as_account_name) {
                $module.FailJson("run_as_account is required when adding a new host cluster.")
            }

            $hg = Get-SCVMHostGroup -Name $host_group_name -ErrorAction SilentlyContinue
            if (-not $hg) {
                $module.FailJson("Host Group '$host_group_name' not found.")
            }

            $raa = Get-SCRunAsAccount -Name $run_as_account_name -ErrorAction SilentlyContinue
            if (-not $raa) {
                $module.FailJson("Run As Account '$run_as_account_name' not found.")
            }

            $addParams = @{
                Name = $name
                VMHostGroup = $hg
                Credential = $raa
                ErrorAction = "Stop"
            }

            if ($null -ne $cluster_reserve) { $addParams.ClusterReserve = $cluster_reserve }
            if ($null -ne $vm_paths) { $addParams.VMPaths = $vm_paths }
            if ($null -ne $remote_connect_enabled) { $addParams.RemoteConnectEnabled = $remote_connect_enabled }
            if ($null -ne $remote_connect_port) { $addParams.RemoteConnectPort = $remote_connect_port }

            if ($module.CheckMode) {
                $module.Result.changed = $true
                $module.ExitJson()
            }

            Add-SCVMHostCluster @addParams
            $module.Result.changed = $true
        }
        else {
            # UPDATE CLUSTER
            $updateParams = @{}
            $changed = $false

            if ($null -ne $cluster_reserve -and $current_cluster.ClusterReserve -ne $cluster_reserve) {
                $updateParams.ClusterReserve = $cluster_reserve
                $changed = $true
            }

            if ($null -ne $description -and $current_cluster.Description -ne $description) {
                $updateParams.Description = $description
                $changed = $true
            }

            if ($null -ne $run_as_account_name) {
                $raa = Get-SCRunAsAccount -Name $run_as_account_name -ErrorAction SilentlyContinue
                if (-not $raa) {
                    $module.FailJson("Run As Account '$run_as_account_name' not found.")
                }

                $current_raa_name = if ($current_cluster.VMHostManagementCredential) { $current_cluster.VMHostManagementCredential.Name } else { $null }

                if ($current_raa_name -ne $run_as_account_name) {
                    $updateParams.VMHostManagementCredential = $raa
                    $changed = $true
                }
            }

            # Note: Set-SCVMHostCluster might not support all parameters like VMPaths directly
            # if they are part of Add-SCVMHostCluster. Research showed ClusterReserve and Description are supported.
            # VMPaths, RemoteConnectEnabled are often part of Set-SCVMHost but sometimes cluster-wide.
            # For this implementation, we focus on what's definitely supported in Set-SCVMHostCluster.

            if ($changed) {
                if ($module.CheckMode) {
                    $module.Result.changed = $true
                    $module.ExitJson()
                }

                Set-SCVMHostCluster -VMHostCluster $current_cluster @updateParams -ErrorAction Stop
                $module.Result.changed = $true
            }
        }
    }
    elseif ($state -eq "absent") {
        if ($current_cluster) {
            # REMOVE CLUSTER
            if ($module.CheckMode) {
                $module.Result.changed = $true
                $module.ExitJson()
            }

            Remove-SCVMHostCluster -VMHostCluster $current_cluster -Confirm:$false -ErrorAction Stop
            $module.Result.changed = $true
        }
    }
}
catch {
    $module.FailJson("Failed to manage SCVMM host cluster: $($_.Exception.Message)", $_)
}

$module.ExitJson()
