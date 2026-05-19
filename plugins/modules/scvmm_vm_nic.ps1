#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm_compute

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        vm_name = @{ type = 'str'; required = $true }
        name = @{ type = 'str' }
        mac_address = @{ type = 'str' }
        vm_network = @{ type = 'str' }
        logical_network = @{ type = 'str' }
        state = @{ type = 'str'; default = 'present'; choices = @('absent', 'present') }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$vm_name = $module.Params.vm_name
$name = $module.Params.name
$mac_address = $module.Params.mac_address
$vm_network_name = $module.Params.vm_network
$logical_network_name = $module.Params.logical_network
$state = $module.Params.state
$vmm_server = $module.Params.vmm_server

try {
    $getParams = @{ Name = $vm_name; ErrorAction = "SilentlyContinue" }
    if ($vmm_server) { $getParams.VMMServer = $vmm_server }

    $vm = Get-SCVirtualMachine @getParams
    if (-not $vm) { $module.FailJson("Virtual machine '$vm_name' not found.") }

    $nic = $null
    $nics = Get-SCVirtualNetworkAdapter -VM $vm
    if ($name) {
        $nic = $nics | Where-Object { $_.Name -eq $name }
    }
    elseif ($mac_address) {
        $nic = $nics | Where-Object { $_.MACAddress -eq $mac_address }
    }
    else {
        # If neither name nor MAC provided, and we are creating, we'll just create a new one.
        # If updating/removing, we need to know which one.
        if ($nics.Count -eq 1) {
            $nic = $nics[0]
        }
    }

    if ($state -eq 'present') {
        if (-not $nic) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                $createParams = @{
                    VM = $vm
                    ErrorAction = "Stop"
                }

                if ($vm_network_name) {
                    $vmn = Get-SCVMNetwork -Name $vm_network_name -ErrorAction SilentlyContinue
                    if (-not $vmn) { $module.FailJson("VM Network '$vm_network_name' not found.") }
                    $createParams.VMNetwork = $vmn
                }
                elseif ($logical_network_name) {
                    $ln = Get-SCVMMLogicalNetwork -Name $logical_network_name -ErrorAction SilentlyContinue
                    if (-not $ln) { $module.FailJson("Logical Network '$logical_network_name' not found.") }
                    $createParams.LogicalNetwork = $ln
                }

                if ($mac_address) { $createParams.MACAddress = $mac_address }

                $nic = New-SCVirtualNetworkAdapter @createParams
            }
        }
        else {
            $changed = $false
            $updateParams = @{ VirtualNetworkAdapter = $nic; ErrorAction = "Stop" }

            if ($vm_network_name) {
                if ($nic.VMNetwork.Name -ne $vm_network_name) {
                    $vmn = Get-SCVMNetwork -Name $vm_network_name -ErrorAction SilentlyContinue
                    if (-not $vmn) { $module.FailJson("VM Network '$vm_network_name' not found.") }
                    $updateParams.VMNetwork = $vmn
                    $changed = $true
                }
            }

            if ($changed) {
                $module.Result.changed = $true
                if (-not $module.CheckMode) {
                    $nic = Set-SCVirtualNetworkAdapter @updateParams
                }
            }
        }
    }
    elseif ($state -eq 'absent') {
        if ($nic) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                Remove-SCVirtualNetworkAdapter -VirtualNetworkAdapter $nic -Force -ErrorAction Stop
                $nic = $null
            }
        }
    }

    if ($nic) {
        $module.Result.vm_nic = Get-SCVMMVirtualNetworkAdapterInfo -Adapter $nic
    }
}
catch {
    $module.FailJson("Failed to manage VM NIC: $($_.Exception.Message)", $_)
}

$module.ExitJson()
