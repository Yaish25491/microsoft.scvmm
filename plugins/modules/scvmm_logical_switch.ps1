#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm_network

$spec = @{
    name = @{ type = "str"; required = $true }
    state = @{ type = "str"; choices = "absent", "present"; default = "present" }
    description = @{ type = "str" }
    enable_sriov = @{ type = "bool" }
    switch_uplink_mode = @{ type = "str"; choices = "NoTeam", "Team", "EmbeddedTeam" }
    minimum_bandwidth_mode = @{ type = "str"; choices = "Default", "Weight", "Absolute", "None" }
    enable_packet_direct = @{ type = "bool" }
}

$module = [Ansible.ModuleUtils.Legacy.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$state = $module.Params.state
$description = $module.Params.description
$enable_sriov = $module.Params.enable_sriov
$switch_uplink_mode = $module.Params.switch_uplink_mode
$minimum_bandwidth_mode = $module.Params.minimum_bandwidth_mode
$enable_packet_direct = $module.Params.enable_packet_direct

# Get current state
$current_ls = $null
try {
    $current_ls = Get-SCLogicalSwitch -Name $name -ErrorAction SilentlyContinue
}
catch {
    $module.FailJson("Failed to query logical switch: $($_.Exception.Message)", $_)
}

if ($state -eq "absent") {
    if ($current_ls) {
        $module.Result.changed = $true
        if (-not $module.CheckMode) {
            try {
                Remove-SCLogicalSwitch -LogicalSwitch $current_ls -ErrorAction Stop
            }
            catch {
                $module.FailJson("Failed to remove logical switch: $($_.Exception.Message)", $_)
            }
        }
    }
    $module.ExitJson()
}

# state is present
if (-not $current_ls) {
    # Create new
    $module.Result.changed = $true

    $create_params = @{
        Name = $name
        ErrorAction = "Stop"
    }
    if ($description) { $create_params.Description = $description }
    if ($null -ne $enable_sriov) { $create_params.EnableSriov = $enable_sriov }
    if ($switch_uplink_mode) { $create_params.SwitchUplinkMode = $switch_uplink_mode }
    if ($minimum_bandwidth_mode) { $create_params.MinimumBandwidthMode = $minimum_bandwidth_mode }
    if ($null -ne $enable_packet_direct) { $create_params.EnablePacketDirect = $enable_packet_direct }

    if (-not $module.CheckMode) {
        try {
            $new_ls = New-SCLogicalSwitch @create_params
            $module.Result.scvmm_logical_switch = Get-SCVMMLogicalSwitchInfo -LogicalSwitch $new_ls
        }
        catch {
            $module.FailJson("Failed to create logical switch: $($_.Exception.Message)", $_)
        }
    }
}
else {
    # Update existing
    $update_params = @{}

    if ($null -ne $description -and $description -ne $current_ls.Description) {
        $update_params.Description = $description
    }

    if ($null -ne $enable_sriov -and $enable_sriov -ne $current_ls.EnableSriov) {
        $update_params.EnableSriov = $enable_sriov
    }

    if ($switch_uplink_mode -and $switch_uplink_mode -ne $current_ls.SwitchUplinkMode.ToString()) {
        $update_params.SwitchUplinkMode = $switch_uplink_mode
    }

    if ($minimum_bandwidth_mode -and $minimum_bandwidth_mode -ne $current_ls.MinimumBandwidthMode.ToString()) {
        $update_params.MinimumBandwidthMode = $minimum_bandwidth_mode
    }

    if ($null -ne $enable_packet_direct -and $enable_packet_direct -ne $current_ls.EnablePacketDirect) {
        $update_params.EnablePacketDirect = $enable_packet_direct
    }

    if ($update_params.Count -gt 0) {
        $module.Result.changed = $true
        if (-not $module.CheckMode) {
            try {
                $updated_ls = Set-SCLogicalSwitch -LogicalSwitch $current_ls @update_params -ErrorAction Stop
                $module.Result.scvmm_logical_switch = Get-SCVMMLogicalSwitchInfo -LogicalSwitch $updated_ls
            }
            catch {
                $module.FailJson("Failed to update logical switch: $($_.Exception.Message)", $_)
            }
        }
    }
    else {
        $module.Result.scvmm_logical_switch = Get-SCVMMLogicalSwitchInfo -LogicalSwitch $current_ls
    }
}

$module.ExitJson()
