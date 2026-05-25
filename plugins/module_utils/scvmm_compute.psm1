# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

function Get-SCVMMVMInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM VM object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a VirtualMachine object and returns a standardized hashtable.
    .PARAMETER VM
    The SCVirtualMachine object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$VM
    )

    $info = @{
        name = $VM.Name
        id = $VM.ID.Guid
        status = if ($VM.Status) { $VM.Status.ToString() } else { $VM.StatusString }
        cpu_count = $VM.CPUCount
        memory = $VM.Memory
        description = $VM.Description
        host_name = if ($VM.VMHost) { $VM.VMHost.Name } else { $null }
        cloud = if ($VM.Cloud) { $VM.Cloud.Name } else { $null }
    }

    return $info
}

function Get-SCVMMVirtualNetworkAdapterInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Virtual Network Adapter object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a VirtualNetworkAdapter object and returns a standardized hashtable.
    .PARAMETER Adapter
    The VirtualNetworkAdapter object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Adapter
    )

    $info = @{
        name = $Adapter.Name
        id = $Adapter.ID.Guid
        vm_name = if ($Adapter.VM) { $Adapter.VM.Name } else { $null }
        vm_template_name = if ($Adapter.VMTemplate) { $Adapter.VMTemplate.Name } else { $null }
        hardware_profile_name = if ($Adapter.HardwareProfile) { $Adapter.HardwareProfile.Name } else { $null }
        mac_address = $Adapter.MACAddress
        mac_address_type = if ($Adapter.MACAddressType) { $Adapter.MACAddressType.ToString() } else { $null }
        ipv4_addresses = $Adapter.IPv4Addresses
        ipv6_addresses = $Adapter.IPv6Addresses
        logical_network = if ($Adapter.LogicalNetwork) { $Adapter.LogicalNetwork.Name } else { $null }
        vm_network = if ($Adapter.VMNetwork) { $Adapter.VMNetwork.Name } else { $null }
        port_classification = if ($Adapter.PortClassification) { $Adapter.PortClassification.Name } else { $null }
        vlan_enabled = $Adapter.VLanEnabled
        vlan_id = $Adapter.VLanID
        enable_mac_address_spoofing = $Adapter.EnableMACAddressSpoofing
    }

    return $info
}

Export-ModuleMember -Function 'Get-SCVMMVMInfo', 'Get-SCVMMVirtualNetworkAdapterInfo'
