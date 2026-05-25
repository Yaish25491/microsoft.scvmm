#!powershell
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_network

#AnsibleRequires -CSharpUtil Ansible.Basic

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = "str"; required = $true }
        description = @{ type = "str" }
        lbfo_load_balancing_algorithm = @{ type = "str"; choices = "HyperVPort", "TransportPorts", "IPAddresses", "MACAddresses", "Dynamic" }
        lbfo_teaming_mode = @{ type = "str"; choices = "SwitchIndependent", "LACP", "Static" }
        enable_network_virtualization = @{ type = "bool" }
        logical_network_definitions = @{ type = "list"; elements = "str" }
        state = @{ type = "str"; choices = "absent", "present"; default = "present" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$description = $module.Params.description
$lbfo_algo = $module.Params.lbfo_load_balancing_algorithm
$lbfo_mode = $module.Params.lbfo_teaming_mode
$enable_nv = $module.Params.enable_network_virtualization
$lnd_names = $module.Params.logical_network_definitions
$state = $module.Params.state

function Get-ResultObject {
    param($UplinkProfile)
    return @{
        uplink_port_profile = Get-SCVMMUplinkPortProfileInfo -UplinkPortProfile $UplinkProfile
    }
}

try {
    Import-SCVMMModule -Module $module

    $existing = Get-SCUplinkPortProfile -Name $name -ErrorAction SilentlyContinue

    if ($state -eq "present") {
        if ($null -eq $existing) {
            # Create
            $params = @{
                Name = $name
                NativeUplinkPortProfile = $true
                ErrorAction = "Stop"
            }

            if ($null -ne $description) { $params.Description = $description }
            if ($null -ne $lbfo_algo) { $params.LBFOLoadBalancingAlgorithm = $lbfo_algo }
            if ($null -ne $lbfo_mode) { $params.LBFOTeamingMode = $lbfo_mode }
            if ($null -ne $enable_nv) { $params.EnableNetworkVirtualization = $enable_nv }

            if ($null -ne $lnd_names) {
                $lnds = @()
                foreach ($lnd_name in $lnd_names) {
                    $lnd = Get-SCLogicalNetworkDefinition -Name $lnd_name -ErrorAction SilentlyContinue
                    if ($null -eq $lnd) { $module.FailJson("Logical network definition '$lnd_name' not found.") }
                    $lnds += $lnd
                }
                $params.LogicalNetworkDefinition = $lnds
            }

            if ($module.CheckMode) {
                $module.ExitJson(@{ changed = $true })
            }

            $new_profile = New-SCUplinkPortProfile @params
            $module.ExitJson(@{ changed = $true } + (Get-ResultObject -UplinkProfile $new_profile))
        }
        else {
            # Update
            $update_params = @{}
            $changed = $false

            if ($null -ne $description -and $existing.Description -ne $description) {
                $update_params.Description = $description
                $changed = $true
            }
            if ($null -ne $lbfo_algo -and $existing.LBFOLoadBalancingAlgorithm.ToString() -ne $lbfo_algo) {
                $update_params.LBFOLoadBalancingAlgorithm = $lbfo_algo
                $changed = $true
            }
            if ($null -ne $lbfo_mode -and $existing.LBFOTeamingMode.ToString() -ne $lbfo_mode) {
                $update_params.LBFOTeamingMode = $lbfo_mode
                $changed = $true
            }
            if ($null -ne $enable_nv -and $existing.EnableNetworkVirtualization -ne $enable_nv) {
                $update_params.EnableNetworkVirtualization = $enable_nv
                $changed = $true
            }

            if ($null -ne $lnd_names) {
                $current_lnds = $existing.LogicalNetworkDefinitions | ForEach-Object { $_.Name }

                $to_add = @()
                $to_remove = @()

                foreach ($lnd_name in $lnd_names) {
                    if ($lnd_name -notin $current_lnds) {
                        $lnd = Get-SCLogicalNetworkDefinition -Name $lnd_name -ErrorAction SilentlyContinue
                        if ($null -eq $lnd) { $module.FailJson("Logical network definition '$lnd_name' not found.") }
                        $to_add += $lnd
                    }
                }

                foreach ($lnd_name in $current_lnds) {
                    if ($lnd_name -notin $lnd_names) {
                        $lnd = Get-SCLogicalNetworkDefinition -Name $lnd_name -ErrorAction SilentlyContinue
                        if ($null -eq $lnd) { $module.FailJson("Logical network definition '$lnd_name' not found.") }
                        $to_remove += $lnd
                    }
                }

                if ($to_add.Count -gt 0) {
                    $update_params.AddLogicalNetworkDefinition = $to_add
                    $changed = $true
                }
                if ($to_remove.Count -gt 0) {
                    $update_params.RemoveLogicalNetworkDefinition = $to_remove
                    $changed = $true
                }
            }

            if ($changed) {
                if ($module.CheckMode) {
                    $module.ExitJson(@{ changed = $true })
                }

                $updated_profile = Set-SCUplinkPortProfile -UplinkPortProfile $existing @update_params -ErrorAction Stop
                $module.ExitJson(@{ changed = $true } + (Get-ResultObject -UplinkProfile $updated_profile))
            }
            else {
                $module.ExitJson(@{ changed = $false } + (Get-ResultObject -UplinkProfile $existing))
            }
        }
    }
    else {
        # absent
        if ($null -ne $existing) {
            if ($module.CheckMode) {
                $module.ExitJson(@{ changed = $true })
            }

            Remove-SCUplinkPortProfile -UplinkPortProfile $existing -ErrorAction Stop
            $module.ExitJson(@{ changed = $true })
        }
        else {
            $module.ExitJson(@{ changed = $false })
        }
    }
}
catch {
    $module.FailJson("Failed to manage SCVMM uplink port profile: $($_.Exception.Message)", $_)
}

$module.ExitJson()
