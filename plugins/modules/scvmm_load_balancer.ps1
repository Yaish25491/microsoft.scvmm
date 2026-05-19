#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

function Get-SCVMMLoadBalancerInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Load Balancer object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a LoadBalancer object and returns a standardized hashtable.
    .PARAMETER LoadBalancer
    The LoadBalancer object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$LoadBalancer
    )

    $info = @{
        name = $LoadBalancer.Name
        id = $LoadBalancer.ID.Guid
        address = $LoadBalancer.Address
        port = $LoadBalancer.Port
        manufacturer = $LoadBalancer.Manufacturer
        model = $LoadBalancer.Model
        description = $LoadBalancer.Description
        host_groups = $LoadBalancer.VMHostGroup | ForEach-Object { $_.Name }
        logical_network_vips = $LoadBalancer.LogicalNetwork | ForEach-Object { $_.Name }
        connection_state = if ($LoadBalancer.ConnectionState) { $LoadBalancer.ConnectionState.ToString() } else { $null }
        enabled = $LoadBalancer.Enabled
    }

    return $info
}

#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm_network

$params = @{
    name = @{ type = 'str'; required = $true }
    state = @{ type = 'str'; choices = 'absent', 'present'; default = 'present' }
    address = @{ type = 'str' }
    port = @{ type = 'int' }
    manufacturer = @{ type = 'str' }
    model = @{ type = 'str' }
    run_as_account = @{ type = 'str' }
    description = @{ type = 'str' }
    host_groups = @{ type = 'list'; elements = 'str' }
    logical_network_vips = @{ type = 'list'; elements = 'str' }
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $params)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$state = $module.Params.state
$address = $module.Params.address
$port = $module.Params.port
$manufacturer = $module.Params.manufacturer
$model = $module.Params.model
$run_as_account_name = $module.Params.run_as_account
$description = $module.Params.description
$host_groups = $module.Params.host_groups
$logical_network_vips = $module.Params.logical_network_vips

$current_lb = $null
try {
    $current_lb = Get-SCLoadBalancer | Where-Object { $_.Name -eq $name }
}
catch {
    $module.FailJson("Failed to retrieve load balancer '$name': $($_.Exception.Message)", $_)
}

if ($state -eq 'absent') {
    if ($null -ne $current_lb) {
        if ($module.CheckMode) {
            $module.Result.changed = $true
        }
        else {
            try {
                Remove-SCLoadBalancer -LoadBalancer $current_lb -ErrorAction Stop
                $module.Result.changed = $true
            }
            catch {
                $module.FailJson("Failed to remove load balancer '$name': $($_.Exception.Message)", $_)
            }
        }
    }
    $module.ExitJson()
}

if ($null -eq $current_lb) {
    if ($null -eq $address -or $null -eq $port -or $null -eq $manufacturer -or $null -eq $model -or $null -eq $run_as_account_name) {
        $module.FailJson("Parameters 'address', 'port', 'manufacturer', 'model', and 'run_as_account' are required when creating a new load balancer.")
    }

    $raa = Get-SCRunAsAccount -Name $run_as_account_name -ErrorAction SilentlyContinue
    if ($null -eq $raa) {
        $module.FailJson("Run As Account '$run_as_account_name' not found.")
    }

    $add_params = @{
        LoadBalancerAddress = $address
        Port = $port
        Manufacturer = $manufacturer
        Model = $model
        RunAsAccount = $raa
        ErrorAction = 'Stop'
    }

    if ($module.CheckMode) {
        $module.Result.changed = $true
        $module.ExitJson()
    }

    try {
        $new_lb = Add-SCLoadBalancer @add_params
        if ($new_lb.Name -ne $name) {
            Set-SCLoadBalancer -LoadBalancer $new_lb -Name $name -ErrorAction Stop
        }
        $current_lb = Get-SCLoadBalancer | Where-Object { $_.Name -eq $name }
        $module.Result.changed = $true
    }
    catch {
        $module.FailJson("Failed to create load balancer '$name': $($_.Exception.Message)", $_)
    }
}

$update_params = @{}
if ($null -ne $address -and $current_lb.Address -ne $address) { $update_params.LoadBalancerAddress = $address }
if ($null -ne $port -and $current_lb.Port -ne $port) { $update_params.Port = $port }
if ($null -ne $manufacturer -and $current_lb.Manufacturer -ne $manufacturer) { $update_params.Manufacturer = $manufacturer }
if ($null -ne $model -and $current_lb.Model -ne $model) { $update_params.Model = $model }
if ($null -ne $description -and $current_lb.Description -ne $description) { $update_params.Description = $description }

if ($null -ne $run_as_account_name) {
    $raa = Get-SCRunAsAccount -Name $run_as_account_name -ErrorAction SilentlyContinue
    if ($null -ne $raa -and $current_lb.RunAsAccount.Name -ne $run_as_account_name) { $update_params.RunAsAccount = $raa }
}

$groups_to_add = @()
$groups_to_remove = @()
if ($null -ne $host_groups) {
    $current_groups = $current_lb.VMHostGroup | ForEach-Object { $_.Name }
    foreach ($g in $host_groups) {
        if ($g -notin $current_groups) {
            $hg = Get-SCVMHostGroup -Name $g -ErrorAction SilentlyContinue
            if ($null -eq $hg) { $module.FailJson("Host Group '$g' not found.") }
            $groups_to_add += $hg
        }
    }
    foreach ($cg in $current_groups) {
        if ($cg -notin $host_groups) {
            $hg = Get-SCVMHostGroup -Name $cg -ErrorAction SilentlyContinue
            if ($null -ne $hg) { $groups_to_remove += $hg }
        }
    }
}

$vips_to_add = @()
$vips_to_remove = @()
if ($null -ne $logical_network_vips) {
    $current_vips = $current_lb.LogicalNetwork | ForEach-Object { $_.Name }
    foreach ($v in $logical_network_vips) {
        if ($v -notin $current_vips) {
            $ln = Get-SCVMMLogicalNetwork -Name $v -ErrorAction SilentlyContinue
            if ($null -eq $ln) { $module.FailJson("Logical Network '$v' not found.") }
            $vips_to_add += $ln
        }
    }
    foreach ($cv in $current_vips) {
        if ($cv -notin $logical_network_vips) {
            $ln = Get-SCVMMLogicalNetwork -Name $cv -ErrorAction SilentlyContinue
            if ($null -ne $ln) { $vips_to_remove += $ln }
        }
    }
}

if ($update_params.Count -gt 0 -or $groups_to_add.Count -gt 0 -or $groups_to_remove.Count -gt 0 -or $vips_to_add.Count -gt 0 -or $vips_to_remove.Count -gt 0) {
    if ($module.CheckMode) {
        $module.Result.changed = $true
    }
    else {
        try {
            if ($update_params.Count -gt 0) {
                $update_params.LoadBalancer = $current_lb
                $update_params.ErrorAction = 'Stop'
                Set-SCLoadBalancer @update_params | Out-Null
            }
            if ($groups_to_add.Count -gt 0) {
                Set-SCLoadBalancer -LoadBalancer $current_lb -AddVMHostGroup $groups_to_add -ErrorAction Stop | Out-Null
            }
            if ($groups_to_remove.Count -gt 0) {
                Set-SCLoadBalancer -LoadBalancer $current_lb -RemoveVMHostGroup $groups_to_remove -ErrorAction Stop | Out-Null
            }
            if ($vips_to_add.Count -gt 0) {
                Set-SCLoadBalancer -LoadBalancer $current_lb -AddLogicalNetworkVIP $vips_to_add -ErrorAction Stop | Out-Null
            }
            if ($vips_to_remove.Count -gt 0) {
                Set-SCLoadBalancer -LoadBalancer $current_lb -RemoveLogicalNetworkVIP $vips_to_remove -ErrorAction Stop | Out-Null
            }
            $current_lb = Get-SCLoadBalancer | Where-Object { $_.Name -eq $name }
            $module.Result.changed = $true
        }
        catch {
            $module.FailJson("Failed to update load balancer '$name': $($_.Exception.Message)", $_)
        }
    }
}

$module.Result.load_balancer = Get-SCVMMLoadBalancerInfo -LoadBalancer $current_lb
$module.ExitJson()
