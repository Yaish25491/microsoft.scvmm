#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm_network

$spec = @{
    options = @{
        name = @{ type = "str"; required = $true }
        state = @{ type = "str"; choices = "absent", "present"; default = "present" }
        description = @{ type = "str" }
        is_public = @{ type = "bool" }
        enable_network_virtualization = @{ type = "bool" }
        logical_network_definition_isolation = @{ type = "bool" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$state = $module.Params.state
$description = $module.Params.description
$is_public = $module.Params.is_public
$enable_network_virtualization = $module.Params.enable_network_virtualization
$logical_network_definition_isolation = $module.Params.logical_network_definition_isolation

$existing = Get-SCLogicalNetwork -Name $name -ErrorAction SilentlyContinue

function Get-ResultObject {
    param($Network)
    return @{
        logical_network = Get-SCVMMLogicalNetworkInfo -LogicalNetwork $Network
    }
}

try {
    if ($state -eq "present") {
        if ($null -eq $existing) {
            # Create
            $params = @{
                Name = $name
                ErrorAction = "Stop"
            }
            if ($null -ne $description) { $params["Description"] = $description }
            if ($null -ne $is_public) { $params["IsPublic"] = $is_public }
            if ($null -ne $enable_network_virtualization) {
                $params["EnableNetworkVirtualization"] = $enable_network_virtualization
            }
            if ($null -ne $logical_network_definition_isolation) {
                $params["LogicalNetworkDefinitionIsolation"] = $logical_network_definition_isolation
            }

            if ($module.CheckMode) {
                $module.ExitJson(@{ changed = $true })
            }

            $new_network = New-SCLogicalNetwork @params
            $module.ExitJson(@{ changed = $true } + (Get-ResultObject -Network $new_network))
        }
        else {
            # Update
            $update_params = @{}
            if ($null -ne $description -and $existing.Description -ne $description) { $update_params["Description"] = $description }
            if ($null -ne $is_public -and $existing.IsPublic -ne $is_public) { $update_params["IsPublic"] = $is_public }
            if ($null -ne $enable_network_virtualization -and $existing.EnableNetworkVirtualization -ne $enable_network_virtualization) {
                $update_params["EnableNetworkVirtualization"] = $enable_network_virtualization
            }
            if ($null -ne $logical_network_definition_isolation -and $existing.LogicalNetworkDefinitionIsolation -ne $logical_network_definition_isolation) {
                $update_params["LogicalNetworkDefinitionIsolation"] = $logical_network_definition_isolation
            }

            if ($update_params.Count -gt 0) {
                if ($module.CheckMode) {
                    $module.ExitJson(@{ changed = $true })
                }

                $updated_network = Set-SCLogicalNetwork -LogicalNetwork $existing @update_params -ErrorAction Stop
                $module.ExitJson(@{ changed = $true } + (Get-ResultObject -Network $updated_network))
            }
            else {
                $module.ExitJson(@{ changed = $false } + (Get-ResultObject -Network $existing))
            }
        }
    }
    else {
        # absent
        if ($null -ne $existing) {
            if ($module.CheckMode) {
                $module.ExitJson(@{ changed = $true })
            }

            Remove-SCLogicalNetwork -LogicalNetwork $existing -ErrorAction Stop
            $module.ExitJson(@{ changed = $true })
        }
        else {
            $module.ExitJson(@{ changed = $false })
        }
    }
}
catch {
    $module.FailJson("Failed to manage logical network: $($_.Exception.Message)", $_)
}
