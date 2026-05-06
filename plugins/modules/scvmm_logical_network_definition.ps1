#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

$spec = @{
    options = @{
        name = @{ type = "str"; required = $true }
        logical_network = @{ type = "str" }
        vm_host_groups = @{ type = "list"; elements = "str" }
        subnet_vlans = @{
            type = "list"
            elements = "dict"
            options = @{
                subnet = @{ type = "str" }
                vlan = @{ type = "int" }
            }
        }
        state = @{ type = "str"; choices = "absent", "present"; default = "present" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$logical_network_name = $module.Params.logical_network
$vm_host_groups = $module.Params.vm_host_groups
$subnet_vlans_params = $module.Params.subnet_vlans
$state = $module.Params.state

$existing = Get-SCLogicalNetworkDefinition -Name $name -ErrorAction SilentlyContinue

function Get-ResultObject {
    param($Definition)
    return @{
        logical_network_definition = Get-SCVMMLogicalNetworkDefinitionInfo -LogicalNetworkDefinition $Definition
    }
}

function New-SCSubnetVLANObject {
    param($SubnetVLANs)
    if ($null -eq $SubnetVLANs) { return $null }
    $objects = @()
    foreach ($item in $SubnetVLANs) {
        $p = @{}
        if ($null -ne $item.subnet) { $p["Subnet"] = $item.subnet }
        if ($null -ne $item.vlan) { $p["VLAN"] = $item.vlan }
        $objects += New-SCSubnetVLan @p
    }
    return $objects
}

try {
    if ($state -eq "present") {
        if ($null -eq $existing) {
            # Create
            if ($null -eq $logical_network_name) {
                $module.FailJson("logical_network is required when creating a new logical network definition.")
            }
            if ($null -eq $vm_host_groups) {
                $module.FailJson("vm_host_groups is required when creating a new logical network definition.")
            }

            $logical_network = Get-SCLogicalNetwork -Name $logical_network_name -ErrorAction SilentlyContinue
            if ($null -eq $logical_network) {
                $module.FailJson("Logical network '$logical_network_name' not found.")
            }

            $host_groups = @()
            foreach ($hg_name in $vm_host_groups) {
                $hg = Get-SCVMHostGroup -Name $hg_name -ErrorAction SilentlyContinue
                if ($null -eq $hg) {
                    $module.FailJson("Host group '$hg_name' not found.")
                }
                $host_groups += $hg
            }

            $params = @{
                Name = $name
                LogicalNetwork = $logical_network
                VMHostGroup = $host_groups
                ErrorAction = "Stop"
            }

            if ($null -ne $subnet_vlans_params) {
                $params["SubnetVLan"] = New-SCSubnetVLANObject -SubnetVLANs $subnet_vlans_params
            }

            if ($module.CheckMode) {
                $module.ExitJson(@{ changed = $true })
            }

            $new_definition = New-SCLogicalNetworkDefinition @params
            $module.ExitJson(@{ changed = $true } + (Get-ResultObject -Definition $new_definition))
        }
        else {
            # Update
            $update_params = @{}

            # Check Host Groups
            if ($null -ne $vm_host_groups) {
                $current_hg_names = $existing.VMHostGroup | ForEach-Object { $_.Name }
                $to_add = @()
                $to_remove = @()

                foreach ($hg_name in $vm_host_groups) {
                    if ($hg_name -notin $current_hg_names) {
                        $hg = Get-SCVMHostGroup -Name $hg_name -ErrorAction SilentlyContinue
                        if ($null -eq $hg) { $module.FailJson("Host group '$hg_name' not found.") }
                        $to_add += $hg
                    }
                }

                foreach ($hg_name in $current_hg_names) {
                    if ($hg_name -notin $vm_host_groups) {
                        $hg = Get-SCVMHostGroup -Name $hg_name -ErrorAction SilentlyContinue
                        if ($null -eq $hg) { $module.FailJson("Host group '$hg_name' not found.") }
                        $to_remove += $hg
                    }
                }

                if ($to_add.Count -gt 0) { $update_params["AddVMHostGroup"] = $to_add }
                if ($to_remove.Count -gt 0) { $update_params["RemoveVMHostGroup"] = $to_remove }
            }

            # Check Subnet VLANs
            if ($null -ne $subnet_vlans_params) {
                $current_subnets = $existing.SubnetVLAN | ForEach-Object {
                    @{ subnet = $_.Subnet; vlan = $_.VLAN }
                } | Sort-Object subnet, vlan

                $desired_subnets = $subnet_vlans_params | ForEach-Object {
                    @{ subnet = $_.subnet; vlan = $_.vlan }
                } | Sort-Object subnet, vlan

                $current_json = $current_subnets | ConvertTo-Json -Compress
                $desired_json = $desired_subnets | ConvertTo-Json -Compress

                if ($current_json -ne $desired_json) {
                    $update_params["SubnetVLan"] = New-SCSubnetVLANObject -SubnetVLANs $subnet_vlans_params
                }
            }

            if ($update_params.Count -gt 0) {
                if ($module.CheckMode) {
                    $module.ExitJson(@{ changed = $true })
                }

                $updated_definition = Set-SCLogicalNetworkDefinition -LogicalNetworkDefinition $existing @update_params -ErrorAction Stop
                $module.ExitJson(@{ changed = $true } + (Get-ResultObject -Definition $updated_definition))
            }
            else {
                $module.ExitJson(@{ changed = $false } + (Get-ResultObject -Definition $existing))
            }
        }
    }
    else {
        # absent
        if ($null -ne $existing) {
            if ($module.CheckMode) {
                $module.ExitJson(@{ changed = $true })
            }

            Remove-SCLogicalNetworkDefinition -LogicalNetworkDefinition $existing -ErrorAction Stop
            $module.ExitJson(@{ changed = $true })
        }
        else {
            $module.ExitJson(@{ changed = $false })
        }
    }
}
catch {
    $module.FailJson("Failed to manage logical network definition: $($_.Exception.Message)", $_)
}

