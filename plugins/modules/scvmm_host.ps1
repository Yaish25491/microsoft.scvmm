#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

# Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm_infra

$params = @{
    name = @{ type = "str"; required = $true; aliases = @("computer_name") }
    host_group = @{ type = "str" }
    description = @{ type = "str" }
    state = @{ type = "str"; choices = @("absent", "present"); default = "present" }
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $params)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$host_group_name = $module.Params.host_group
$description = $module.Params.description
$state = $module.Params.state

$result = @{
    changed = $false
}

function Get-SCVMHostInfo {
    param ([Parameter(Mandatory = $true)][Object]$VMHost)
    return @{
        name = $VMHost.Name
        id = $VMHost.ID.Guid
        description = $VMHost.Description
        host_group = $VMHost.VMHostGroup.Name
        state = $VMHost.State.ToString()
    }
}

try {
    $existing_host = Get-SCVMHost -ComputerName $name -ErrorAction SilentlyContinue

    if ($state -eq "present") {
        if (-not $existing_host) {
            # Add new host
            if (-not $host_group_name) {
                $module.FailJson("host_group is required when adding a new host.")
            }

            $host_group = Get-SCVMHostGroup -Name $host_group_name -ErrorAction Stop

            $add_params = @{
                ComputerName = $name
                VMHostGroup = $host_group
            }
            if ($description) { $add_params.Description = $description }

            if (-not $module.CheckMode) {
                $existing_host = Add-SCVMHost @add_params -ErrorAction Stop
            }
            $result.changed = $true
        }
        else {
            # Update existing host
            $update_params = @{}

            if ($null -ne $description -and $existing_host.Description -ne $description) {
                $update_params.Description = $description
            }

            if ($host_group_name -and $existing_host.VMHostGroup.Name -ne $host_group_name) {
                $host_group = Get-SCVMHostGroup -Name $host_group_name -ErrorAction Stop
                $update_params.VMHostGroup = $host_group
            }

            if ($update_params.Count -gt 0) {
                if (-not $module.CheckMode) {
                    $existing_host = Set-SCVMHost -VMHost $existing_host @update_params -ErrorAction Stop
                }
                $result.changed = $true
            }
        }

        if ($existing_host) {
            $result.host = Get-SCVMHostInfo -VMHost $existing_host
        }
    }
    else {
        # state -eq "absent"
        if ($existing_host) {
            if (-not $module.CheckMode) {
                Remove-SCVMHost -VMHost $existing_host -Confirm:$false -ErrorAction Stop
            }
            $result.changed = $true
        }
    }
}
catch {
    $module.FailJson("An error occurred: $($_.Exception.Message)", $_)
}

$module.ExitJson($result)
