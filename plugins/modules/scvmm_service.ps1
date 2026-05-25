#!powershell
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_service

$spec = @{
    options = @{
        name = @{ type = "str"; required = $true }
        state = @{ type = "str"; choices = @("present", "absent", "started", "stopped"); default = "present" }
        service_configuration = @{ type = "str" }
        description = @{ type = "str" }
        owner = @{ type = "str" }
        user_role = @{ type = "str" }
        cost_center = @{ type = "str" }
        release = @{ type = "str" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$state = $module.Params.state
$service_configuration_name = $module.Params.service_configuration
$description = $module.Params.description
$owner = $module.Params.owner
$user_role_name = $module.Params.user_role
$cost_center = $module.Params.cost_center
$release = $module.Params.release

$module.Result.changed = $false

try {
    $service = Get-SCService -Name $name -ErrorAction Ignore
}
catch {
    $global:Error.Clear()
    $module.FailJson("Failed to check if service exists: $($_.Exception.Message)")
}

if ($state -eq "absent") {
    if ($service) {
        $module.Result.changed = $true
        if (-not $module.CheckMode) {
            try {
                Remove-SCService -Service $service -ErrorAction Stop
            }
            catch {
                $global:Error.Clear()
                $module.FailJson("Failed to remove service: $($_.Exception.Message)")
            }
        }
    }
}
else {
    # state is present, started, or stopped
    if (-not $service) {
        if (-not $service_configuration_name) {
            $module.FailJson("service_configuration is required when creating a new service.")
        }

        $module.Result.changed = $true
        if (-not $module.CheckMode) {
            try {
                $service_config = Get-SCServiceConfiguration -Name $service_configuration_name -ErrorAction Stop
                if (-not $service_config) {
                    $module.FailJson("Service Configuration '$service_configuration_name' not found.")
                }

                $params = @{
                    ServiceConfiguration = $service_config
                    Name = $name
                    ErrorAction = "Stop"
                }
                if ($description) { $params.Description = $description }
                if ($owner) { $params.Owner = $owner }
                if ($user_role_name) {
                    $user_role = Get-SCUserRole -Name $user_role_name -ErrorAction Stop
                    if (-not $user_role) {
                        $module.FailJson("User Role '$user_role_name' not found.")
                    }
                    $params.UserRole = $user_role
                }
                # CostCenter and Release are typically set via Set-SCService or on ServiceConfiguration,
                # but New-SCService might not support them directly. We will apply them after creation if needed.

                $service = New-SCService @params
            }
            catch {
                $global:Error.Clear()
                $module.FailJson("Failed to create service: $($_.Exception.Message)")
            }
        }
    }

    # Update properties if it exists or was just created (and not in check mode if just created)
    if ($service) {
        $update_params = @{
            Service = $service
            ErrorAction = "Stop"
        }
        $needs_update = $false

        if ($null -ne $description -and $service.Description -ne $description) {
            $update_params.Description = $description
            $needs_update = $true
        }
        if ($null -ne $owner -and $service.Owner -ne $owner) {
            $update_params.Owner = $owner
            $needs_update = $true
        }
        if ($null -ne $user_role_name -and ($service.UserRole.Name -ne $user_role_name)) {
            try {
                $user_role = Get-SCUserRole -Name $user_role_name -ErrorAction Stop
                if (-not $user_role) {
                    $module.FailJson("User Role '$user_role_name' not found.")
                }
                $update_params.UserRole = $user_role
                $needs_update = $true
            }
            catch {
                $global:Error.Clear()
                $module.FailJson("Failed to get User Role: $($_.Exception.Message)")
            }
        }
        if ($null -ne $cost_center -and $service.CostCenter -ne $cost_center) {
            $update_params.CostCenter = $cost_center
            $needs_update = $true
        }
        if ($null -ne $release -and $service.Release -ne $release) {
            $update_params.Release = $release
            $needs_update = $true
        }

        if ($needs_update) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                try {
                    $service = Set-SCService @update_params
                }
                catch {
                    $global:Error.Clear()
                    $module.FailJson("Failed to update service: $($_.Exception.Message)")
                }
            }
        }

        # Handle start/stop
        if ($state -eq "started" -and $service.Status -eq "Stopped") {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                try {
                    Start-SCService -Service $service -ErrorAction Stop
                    $service = Get-SCService -Name $name -ErrorAction Ignore
                }
                catch {
                    $global:Error.Clear()
                    $module.FailJson("Failed to start service: $($_.Exception.Message)")
                }
            }
        }
        elseif ($state -eq "stopped" -and $service.Status -ne "Stopped") {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                try {
                    Stop-SCService -Service $service -ErrorAction Stop
                    $service = Get-SCService -Name $name -ErrorAction Ignore
                }
                catch {
                    $global:Error.Clear()
                    $module.FailJson("Failed to stop service: $($_.Exception.Message)")
                }
            }
        }

        if (-not $module.CheckMode) {
            $module.Result.service = Get-SCVMMServiceInfo -Service $service
        }
    }
}

$module.ExitJson()
