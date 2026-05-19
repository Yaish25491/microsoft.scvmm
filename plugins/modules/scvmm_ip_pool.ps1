#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm_network

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        logical_network_definition = @{ type = 'str' }
        ip_address_range_start = @{ type = 'str' }
        ip_address_range_end = @{ type = 'str' }
        description = @{ type = 'str' }
        state = @{ type = 'str'; default = 'present'; choices = @('absent', 'present') }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$lnd_name = $module.Params.logical_network_definition
$range_start = $module.Params.ip_address_range_start
$range_end = $module.Params.ip_address_range_end
$description = $module.Params.description
$state = $module.Params.state
$vmm_server = $module.Params.vmm_server

try {
    $getParams = @{ Name = $name; ErrorAction = "SilentlyContinue" }
    if ($vmm_server) { $getParams.VMMServer = $vmm_server }
    $pool = Get-SCStaticIPAddressPool @getParams

    if ($state -eq 'present') {
        if (-not $pool) {
            if (-not $lnd_name) { $module.FailJson("logical_network_definition is required for creating a new IP pool.") }
            $lndParams = @{ Name = $lnd_name; ErrorAction = "SilentlyContinue" }
            if ($vmm_server) { $lndParams.VMMServer = $vmm_server }
            $lnd = Get-SCLogicalNetworkDefinition @lndParams
            if (-not $lnd) { $module.FailJson("Logical network definition '$lnd_name' not found.") }

            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                $params = @{
                    Name = $name
                    LogicalNetworkDefinition = $lnd
                    IPAddressRangeStart = $range_start
                    IPAddressRangeEnd = $range_end
                    ErrorAction = "Stop"
                }
                if ($description) { $params.Description = $description }
                if ($vmm_server) { $params.VMMServer = $vmm_server }
                $pool = New-SCStaticIPAddressPool @params
            }
        }
        else {
            $changed = $false
            $update_params = @{ StaticIPAddressPool = $pool; ErrorAction = "Stop" }

            if ($null -ne $description -and $pool.Description -ne $description) {
                $update_params.Description = $description
                $changed = $true
            }

            if ($changed) {
                $module.Result.changed = $true
                if (-not $module.CheckMode) {
                    $pool = Set-SCStaticIPAddressPool @update_params
                }
            }
        }
    }
    elseif ($state -eq 'absent') {
        if ($pool) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                Remove-SCStaticIPAddressPool -StaticIPAddressPool $pool -Force -ErrorAction Stop
                $pool = $null
            }
        }
    }

    if ($pool) {
        $module.Result.ip_pool = Get-SCVMMIPPoolInfo -IPPool $pool
    }
}
catch {
    $module.FailJson("Failed to manage IP pool: $($_.Exception.Message)", $_)
}

$module.ExitJson()
