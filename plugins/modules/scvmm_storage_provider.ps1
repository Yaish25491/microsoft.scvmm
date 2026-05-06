#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

$spec = @{
    options = @{
        name = @{ type = "str"; required = $true }
        state = @{ type = "str"; choices = "absent", "present"; default = "present" }
        description = @{ type = "str" }
        computer_name = @{ type = "str" }
        network_device_name = @{ type = "str" }
        tcp_port = @{ type = "int" }
        run_as_account = @{ type = "str" }
        fabric = @{ type = "bool" }
        is_non_trusted_domain = @{ type = "bool" }
        provider_type = @{ type = "str"; choices = "smis_wmi", "windows_native_wmi"; default = "windows_native_wmi" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$state = $module.Params.state
$description = $module.Params.description
$computer_name = $module.Params.computer_name
$network_device_name = $module.Params.network_device_name
$tcp_port = $module.Params.tcp_port
$run_as_account_name = $module.Params.run_as_account
$fabric = $module.Params.fabric
$is_non_trusted_domain = $module.Params.is_non_trusted_domain
$provider_type = $module.Params.provider_type

$existing = Get-SCStorageProvider -Name $name -ErrorAction SilentlyContinue

function Get-ResultObject {
    param($Provider)
    return @{
        storage_provider = Get-SCVMMStorageProviderInfo -StorageProvider $Provider
    }
}

try {
    if ($state -eq "present") {
        if ($null -eq $existing) {
            # Add
            if ($null -eq $computer_name) {
                $module.FailJson("computer_name is required when adding a storage provider.")
            }

            $params = @{
                Name = $name
                ComputerName = $computer_name
                ErrorAction = "Stop"
            }
            if ($null -ne $description) { $params["Description"] = $description }
            if ($null -ne $network_device_name) { $params["NetworkDeviceName"] = $network_device_name }
            if ($null -ne $tcp_port) { $params["TCPPort"] = $tcp_port }
            if ($null -ne $fabric) { $params["Fabric"] = $fabric }
            if ($null -ne $is_non_trusted_domain) { $params["IsNonTrustedDomain"] = $is_non_trusted_domain }

            if ($null -ne $run_as_account_name) {
                $run_as_account = Get-SCRunAsAccount -Name $run_as_account_name -ErrorAction SilentlyContinue
                if ($null -eq $run_as_account) {
                    $module.FailJson("Run As account '$run_as_account_name' not found.")
                }
                $params["RunAsAccount"] = $run_as_account
            }

            if ($provider_type -eq "smis_wmi") {
                $params["AddSmisWmiProvider"] = $true
            }
            else {
                $params["AddWindowsNativeWmiProvider"] = $true
            }

            if ($module.CheckMode) {
                $module.ExitJson(@{ changed = $true })
            }

            $new_provider = Add-SCStorageProvider @params
            $module.ExitJson(@{ changed = $true } + (Get-ResultObject -Provider $new_provider))
        }
        else {
            # Update
            $update_params = @{}
            if ($null -ne $description -and $existing.Description -ne $description) {
                $update_params["Description"] = $description
            }
            if ($null -ne $network_device_name -and $existing.NetworkDeviceName -ne $network_device_name) {
                $update_params["NetworkDeviceName"] = $network_device_name
            }
            if ($null -ne $tcp_port -and $existing.TCPPort -ne $tcp_port) {
                $update_params["TCPPort"] = $tcp_port
            }

            if ($null -ne $run_as_account_name) {
                $run_as_account = Get-SCRunAsAccount -Name $run_as_account_name -ErrorAction SilentlyContinue
                if ($null -eq $run_as_account) {
                    $module.FailJson("Run As account '$run_as_account_name' not found.")
                }
                if ($existing.RunAsAccount.Name -ne $run_as_account_name) {
                    $update_params["RunAsAccount"] = $run_as_account
                }
            }

            if ($update_params.Count -gt 0) {
                if ($module.CheckMode) {
                    $module.ExitJson(@{ changed = $true })
                }

                $updated_provider = Set-SCStorageProvider -StorageProvider $existing @update_params -ErrorAction Stop
                $module.ExitJson(@{ changed = $true } + (Get-ResultObject -Provider $updated_provider))
            }
            else {
                $module.ExitJson(@{ changed = $false } + (Get-ResultObject -Provider $existing))
            }
        }
    }
    else {
        # absent
        if ($null -ne $existing) {
            if ($module.CheckMode) {
                $module.ExitJson(@{ changed = $true })
            }

            Remove-SCStorageProvider -StorageProvider $existing -ErrorAction Stop
            $module.ExitJson(@{ changed = $true })
        }
        else {
            $module.ExitJson(@{ changed = $false })
        }
    }
}
catch {
    $module.FailJson("Failed to manage storage provider: $($_.Exception.Message)", $_)
}
