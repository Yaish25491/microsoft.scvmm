#!powershell
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_network

#AnsibleRequires -CSharpUtil Ansible.Basic

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        vm_host = @{ type = "str"; required = $true }
        name = @{ type = "str"; required = $true }
        logical_network = @{ type = "str" }
        ip_address_pool = @{ type = "str" }
        state = @{ type = "str"; choices = @("present"); default = "present" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$vm_host_name = $module.Params.vm_host
$name = $module.Params.name
$logical_network_name = $module.Params.logical_network
$ip_address_pool_name = $module.Params.ip_address_pool

try {
    Import-SCVMMModule -Module $module

    # Get Host
    $vm_host = Get-SCVMHost -Name $vm_host_name -ErrorAction SilentlyContinue
    if ($null -eq $vm_host) {
        $module.FailJson("VM Host '$vm_host_name' not found.")
    }

    # Get Adapter
    $adapter = Get-SCVMHostNetworkAdapter -VMHost $vm_host -Name $name -ErrorAction SilentlyContinue
    if ($null -eq $adapter) {
        $module.FailJson("Host network adapter '$name' not found on host '$vm_host_name'.")
    }

    $update_params = @{}

    # Logical Network assignment
    if ($null -ne $logical_network_name) {
        $logical_network = Get-SCLogicalNetwork -Name $logical_network_name -ErrorAction SilentlyContinue
        if ($null -eq $logical_network) {
            $module.FailJson("Logical network '$logical_network_name' not found.")
        }

        # Check if already assigned
        $current_lns = $adapter.LogicalNetwork | ForEach-Object { $_.Name }
        if ($logical_network_name -notin $current_lns) {
            $update_params.AddOrSetLogicalNetwork = $logical_network
        }
    }

    # IP Address Pool assignment
    if ($null -ne $ip_address_pool_name) {
        # SCVMM might not have a direct Get-SCStaticIPAddressPool that filters well,
        # usually it's associated with a logical network or subnet.
        $ip_pool = Get-SCStaticIPAddressPool -Name $ip_address_pool_name -ErrorAction SilentlyContinue
        if ($null -eq $ip_pool) {
            $module.FailJson("IP address pool '$ip_address_pool_name' not found.")
        }

        # Check if already assigned (Set-SCVMHostNetworkAdapter takes IPAddressPool)
        # Note: Depending on SCVMM version, this might be complex to check idempotency for perfectly
        # without deeper object inspection.
        # For now, we'll try to set it if provided.
        $update_params.IPAddressPool = $ip_pool
    }

    if ($update_params.Count -gt 0) {
        $module.Result.changed = $true

        if ($module.CheckMode) {
            $module.Result.host_network_adapter = Get-SCVMMHostNetworkAdapterInfo -Adapter $adapter
            # Overlay changes for check mode return
            if ($update_params.AddOrSetLogicalNetwork) {
                $module.Result.host_network_adapter.logical_networks += $logical_network_name
            }
            $module.ExitJson()
        }

        try {
            $adapter = Set-SCVMHostNetworkAdapter -VMHostNetworkAdapter $adapter @update_params -ErrorAction Stop
        }
        catch {
            $module.FailJson("Failed to update host network adapter '$name': $($_.Exception.Message)", $_)
        }
    }

    $module.Result.host_network_adapter = Get-SCVMMHostNetworkAdapterInfo -Adapter $adapter
}
catch {
    $module.FailJson("An unexpected error occurred: $($_.Exception.Message)", $_)
}

$module.ExitJson()
