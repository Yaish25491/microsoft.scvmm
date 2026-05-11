#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module Ansible.ModuleUtils.CommandUtil

$ErrorActionPreference = 'Stop'

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        state = @{ type = 'str'; choices = @('absent', 'present'); default = 'present' }
        description = @{ type = 'str' }
        owner = @{ type = 'str' }
        memory_mb = @{ type = 'int' }
        cpu_count = @{ type = 'int' }
        cpu_type = @{ type = 'str' }
        highly_available = @{ type = 'bool' }
        dynamic_memory_enabled = @{ type = 'bool' }
        dynamic_memory_minimum_mb = @{ type = 'int' }
        dynamic_memory_maximum_mb = @{ type = 'int' }
        dynamic_memory_buffer_percentage = @{ type = 'int' }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$state = $module.Params.state
$description = $module.Params.description
$owner = $module.Params.owner
$memory_mb = $module.Params.memory_mb
$cpu_count = $module.Params.cpu_count
$cpu_type_str = $module.Params.cpu_type
$highly_available = $module.Params.highly_available
$dynamic_memory_enabled = $module.Params.dynamic_memory_enabled
$dynamic_memory_minimum_mb = $module.Params.dynamic_memory_minimum_mb
$dynamic_memory_maximum_mb = $module.Params.dynamic_memory_maximum_mb
$dynamic_memory_buffer_percentage = $module.Params.dynamic_memory_buffer_percentage
$vmm_server = $module.Params.vmm_server

$module_utils_path = Join-Path -Path $module.ModuleDir -ChildPath '..\module_utils\scvmm.psm1'
Import-Module -Name $module_utils_path -ErrorAction Stop

Import-SCVMMModule -Module $module

$params = @{}
if ($vmm_server) {
    $params['VMMServer'] = $vmm_server
}

function Get-HardwareProfile {
    $existing_profile = Get-SCHardwareProfile -Name $name @params -ErrorAction Ignore
    if ($existing_profile.Count -gt 1) {
        $module.FailJson("Multiple Hardware Profiles found with the name '$name'. Please provide a unique name.")
    }
    return $existing_profile
}

$hw_profile = Get-HardwareProfile

if ($state -eq 'absent') {
    if ($hw_profile) {
        if (-not $module.CheckMode) {
            try {
                Remove-SCHardwareProfile -HardwareProfile $hw_profile @params -ErrorAction Stop | Out-Null
            }
            catch {
                $global:Error.Clear()
                $module.FailJson("Failed to remove hardware profile: $($_.Exception.Message)")
            }
        }
        $module.Result.changed = $true
    }
}
elseif ($state -eq 'present') {
    $cpu_type_obj = $null
    if ($null -ne $cpu_type_str) {
        $cpu_type_obj = Get-SCCPUType @params | Where-Object { $_.Name -eq $cpu_type_str }
        if (-not $cpu_type_obj) {
            $module.FailJson("CPU Type '$cpu_type_str' not found.")
        }
    }

    if (-not $hw_profile) {
        $module.Result.changed = $true

        if (-not $module.CheckMode) {
            $new_params = @{ Name = $name }
            if ($null -ne $description) { $new_params['Description'] = $description }
            if ($null -ne $owner) { $new_params['Owner'] = $owner }
            if ($null -ne $memory_mb) { $new_params['MemoryMB'] = $memory_mb }
            if ($null -ne $cpu_count) { $new_params['CPUCount'] = $cpu_count }
            if ($null -ne $cpu_type_obj) { $new_params['CPUType'] = $cpu_type_obj }
            if ($null -ne $highly_available) { $new_params['HighlyAvailable'] = $highly_available }
            if ($null -ne $dynamic_memory_enabled) { $new_params['DynamicMemoryEnabled'] = $dynamic_memory_enabled }
            if ($null -ne $dynamic_memory_minimum_mb) { $new_params['DynamicMemoryMinimumMB'] = $dynamic_memory_minimum_mb }
            if ($null -ne $dynamic_memory_maximum_mb) { $new_params['DynamicMemoryMaximumMB'] = $dynamic_memory_maximum_mb }
            if ($null -ne $dynamic_memory_buffer_percentage) { $new_params['DynamicMemoryBufferPercentage'] = $dynamic_memory_buffer_percentage }
            foreach ($key in $params.Keys) { $new_params[$key] = $params[$key] }

            try {
                $hw_profile = New-SCHardwareProfile @new_params -ErrorAction Stop
            }
            catch {
                $global:Error.Clear()
                $module.FailJson("Failed to create hardware profile: $($_.Exception.Message)")
            }
        }
    }
    else {
        $set_params = @{ HardwareProfile = $hw_profile }
        $needs_update = $false

        if ($null -ne $description -and $hw_profile.Description -ne $description) {
            $set_params['Description'] = $description
            $needs_update = $true
        }
        if ($null -ne $owner -and $hw_profile.Owner -ne $owner) {
            $set_params['Owner'] = $owner
            $needs_update = $true
        }
        if ($null -ne $memory_mb -and $hw_profile.MemoryMB -ne $memory_mb) {
            $set_params['MemoryMB'] = $memory_mb
            $needs_update = $true
        }
        if ($null -ne $cpu_count -and $hw_profile.CPUCount -ne $cpu_count) {
            $set_params['CPUCount'] = $cpu_count
            $needs_update = $true
        }
        if ($null -ne $cpu_type_obj -and $hw_profile.CPUType.Name -ne $cpu_type_obj.Name) {
            $set_params['CPUType'] = $cpu_type_obj
            $needs_update = $true
        }
        if ($null -ne $highly_available -and $hw_profile.HighlyAvailable -ne $highly_available) {
            $set_params['HighlyAvailable'] = $highly_available
            $needs_update = $true
        }
        if ($null -ne $dynamic_memory_enabled -and $hw_profile.DynamicMemoryEnabled -ne $dynamic_memory_enabled) {
            $set_params['DynamicMemoryEnabled'] = $dynamic_memory_enabled
            $needs_update = $true
        }
        if ($null -ne $dynamic_memory_minimum_mb -and $hw_profile.DynamicMemoryMinimumMB -ne $dynamic_memory_minimum_mb) {
            $set_params['DynamicMemoryMinimumMB'] = $dynamic_memory_minimum_mb
            $needs_update = $true
        }
        if ($null -ne $dynamic_memory_maximum_mb -and $hw_profile.DynamicMemoryMaximumMB -ne $dynamic_memory_maximum_mb) {
            $set_params['DynamicMemoryMaximumMB'] = $dynamic_memory_maximum_mb
            $needs_update = $true
        }
        if ($null -ne $dynamic_memory_buffer_percentage -and $hw_profile.DynamicMemoryBufferPercentage -ne $dynamic_memory_buffer_percentage) {
            $set_params['DynamicMemoryBufferPercentage'] = $dynamic_memory_buffer_percentage
            $needs_update = $true
        }

        if ($needs_update) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                foreach ($key in $params.Keys) { $set_params[$key] = $params[$key] }
                try {
                    $hw_profile = Set-SCHardwareProfile @set_params -ErrorAction Stop
                }
                catch {
                    $global:Error.Clear()
                    $module.FailJson("Failed to update hardware profile: $($_.Exception.Message)")
                }
            }
        }
    }
}

if ($hw_profile) {
    if ($module.CheckMode -and $state -eq 'present' -and $null -eq $hw_profile.ID) {
        # Profile is created in check mode, provide a mock response
        $module.Result.hardware_profile = @{
            name = $name
            description = $description
            owner = $owner
            memory_mb = $memory_mb
            cpu_count = $cpu_count
            cpu_type = if ($cpu_type_obj) { $cpu_type_obj.Name } else { $null }
            highly_available = $highly_available
            dynamic_memory_enabled = $dynamic_memory_enabled
            dynamic_memory_minimum_mb = $dynamic_memory_minimum_mb
            dynamic_memory_maximum_mb = $dynamic_memory_maximum_mb
            dynamic_memory_buffer_percentage = $dynamic_memory_buffer_percentage
        }
    }
    else {
        # For actual profile object or existing profile during check_mode update
        $module.Result.hardware_profile = Get-SCVMMHardwareProfileInfo -HardwareProfile $hw_profile
    }
}

$global:Error.Clear()
$module.ExitJson()