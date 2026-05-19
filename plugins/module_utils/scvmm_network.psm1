# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

function Get-SCVMMVMNetworkInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM VM Network object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a VMNetwork object and returns a standardized hashtable.
    .PARAMETER VMNetwork
    The VMNetwork object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$VMNetwork
    )

    $info = @{
        name = $VMNetwork.Name
        id = $VMNetwork.ID.Guid
        description = $VMNetwork.Description
        logical_network = if ($VMNetwork.LogicalNetwork) { $VMNetwork.LogicalNetwork.Name } else { $null }
        isolation_type = if ($VMNetwork.IsolationType) { $VMNetwork.IsolationType.ToString() } else { $null }
        vm_network_type = if ($VMNetwork.VMNetworkType) { $VMNetwork.VMNetworkType.ToString() } else { $null }
        ipv4_pa_address_pool_type = if ($VMNetwork.IPv4PAAddressPoolType) { $VMNetwork.IPv4PAAddressPoolType.ToString() } else { $null }
        ipv6_pa_address_pool_type = if ($VMNetwork.IPv6PAAddressPoolType) { $VMNetwork.IPv6PAAddressPoolType.ToString() } else { $null }
    }

    return $info
}

function Get-SCVMMLogicalNetworkInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Logical Network object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a LogicalNetwork object and returns a standardized hashtable.
    .PARAMETER LogicalNetwork
    The LogicalNetwork object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$LogicalNetwork
    )

    $info = @{
        name = $LogicalNetwork.Name
        id = $LogicalNetwork.ID.Guid
        description = $LogicalNetwork.Description
        enable_network_virtualization = $LogicalNetwork.EnableNetworkVirtualization
        logical_network_definition_isolation = $LogicalNetwork.LogicalNetworkDefinitionIsolation
        is_public = $LogicalNetwork.IsPublic
        network_manager = if ($LogicalNetwork.NetworkManager) { $LogicalNetwork.NetworkManager.Name } else { $null }
    }

    return $info
}

function Get-SCVMMLogicalNetworkDefinitionInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Logical Network Definition object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a LogicalNetworkDefinition object and returns a standardized hashtable.
    .PARAMETER LogicalNetworkDefinition
    The LogicalNetworkDefinition object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$LogicalNetworkDefinition
    )

    $info = @{
        name = $LogicalNetworkDefinition.Name
        id = $LogicalNetworkDefinition.ID.Guid
        logical_network = if ($LogicalNetworkDefinition.LogicalNetwork) { $LogicalNetworkDefinition.LogicalNetwork.Name } else { $null }
        vm_host_groups = $LogicalNetworkDefinition.VMHostGroup | ForEach-Object { $_.Name }
        subnet_vlans = $LogicalNetworkDefinition.SubnetVLAN | ForEach-Object {
            @{
                subnet = $_.Subnet
                vlan = $_.VLAN
            }
        }
    }

    return $info
}

function Get-SCVMMLogicalSwitchInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Logical Switch object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a LogicalSwitch object and returns a standardized hashtable.
    .PARAMETER LogicalSwitch
    The LogicalSwitch object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$LogicalSwitch
    )

    $info = @{
        name = $LogicalSwitch.Name
        id = $LogicalSwitch.ID.Guid
        description = $LogicalSwitch.Description
        enable_sriov = $LogicalSwitch.EnableSriov
        switch_uplink_mode = if ($LogicalSwitch.SwitchUplinkMode) { $LogicalSwitch.SwitchUplinkMode.ToString() } else { $null }
        minimum_bandwidth_mode = if ($LogicalSwitch.MinimumBandwidthMode) { $LogicalSwitch.MinimumBandwidthMode.ToString() } else { $null }
        enable_packet_direct = $LogicalSwitch.EnablePacketDirect
        virtual_switch_extensions = $LogicalSwitch.VirtualSwitchExtensions | ForEach-Object { Get-SCVMMLogicalSwitchExtensionInfo -Extension $_ }
    }

    return $info
}

function Get-SCVMMVMSubnetInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM VM Subnet object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a VMSubnet object and returns a standardized hashtable.
    .PARAMETER VMSubnet
    The VMSubnet object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$VMSubnet
    )

    $info = @{
        name = $VMSubnet.Name
        id = $VMSubnet.ID.Guid
        description = $VMSubnet.Description
        vm_network = if ($VMSubnet.VMNetwork) { $VMSubnet.VMNetwork.Name } else { $null }
        subnet_vlans = $VMSubnet.SubnetVLans | ForEach-Object {
            @{
                subnet = $_.Subnet
                vlan = $_.VLanID
            }
        }
        max_number_of_ports = $VMSubnet.MaxNumberOfPorts
        port_acl = if ($VMSubnet.PortACL) { $VMSubnet.PortACL.Name } else { $null }
    }

    return $info
}

function Get-SCVMMMACAddressPoolInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM MAC Address Pool object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a MACAddressPool object and returns a standardized hashtable.
    .PARAMETER MACAddressPool
    The SCMACAddressPool object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$MACAddressPool
    )

    $info = @{
        name = $MACAddressPool.Name
        id = $MACAddressPool.ID.Guid
        description = $MACAddressPool.Description
        mac_address_range_start = $MACAddressPool.MACAddressRangeStart
        mac_address_range_end = $MACAddressPool.MACAddressRangeEnd
        host_groups = $MACAddressPool.VMHostGroups | ForEach-Object { $_.Name }
    }

    return $info
}

function Get-SCVMMUplinkPortProfileInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Uplink Port Profile object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a NativeUplinkPortProfile object and returns a standardized hashtable.
    .PARAMETER UplinkPortProfile
    The NativeUplinkPortProfile object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$UplinkPortProfile
    )

    $info = @{
        name = $UplinkPortProfile.Name
        id = $UplinkPortProfile.ID.Guid
        description = $UplinkPortProfile.Description
        lbfo_load_balancing_algorithm = if ($UplinkPortProfile.LBFOLoadBalancingAlgorithm) {
            $UplinkPortProfile.LBFOLoadBalancingAlgorithm.ToString()
        }
        else { $null }
        lbfo_teaming_mode = if ($UplinkPortProfile.LBFOTeamingMode) {
            $UplinkPortProfile.LBFOTeamingMode.ToString()
        }
        else { $null }
        enable_network_virtualization = $UplinkPortProfile.EnableNetworkVirtualization
        logical_network_definitions = $UplinkPortProfile.LogicalNetworkDefinitions | ForEach-Object { $_.Name }
    }

    return $info
}

function Get-SCVMMPortClassificationInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Port Classification object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a PortClassification object and returns a standardized hashtable.
    .PARAMETER PortClassification
    The PortClassification object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$PortClassification
    )

    $info = @{
        name = $PortClassification.Name
        id = $PortClassification.ID.Guid
        description = $PortClassification.Description
    }

    return $info
}

function Get-SCVMMHostNetworkAdapterInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Host Network Adapter object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a HostNetworkAdapter object and returns a standardized hashtable.
    .PARAMETER Adapter
    The HostNetworkAdapter object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Adapter
    )

    $info = @{
        name = $Adapter.Name
        id = $Adapter.ID.Guid
        connection_name = $Adapter.ConnectionName
        vm_host = if ($Adapter.VMHost) { $Adapter.VMHost.Name } else { $null }
        mac_address = $Adapter.MACAddress
        vlan_enabled = $Adapter.VLanEnabled
        vlan_mode = if ($Adapter.VLanMode) { $Adapter.VLanMode.ToString() } else { $null }
        vlan_id = $Adapter.VLanID
        vlan_trunk_ids = $Adapter.VLanTrunkID
        logical_networks = $Adapter.LogicalNetwork | ForEach-Object { $_.Name }
        available_for_placement = $Adapter.AvailableForPlacement
    }

    return $info
}

function Get-SCVMMIPPoolInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM IP Pool object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a StaticIPAddressPool object and returns a standardized hashtable.
    .PARAMETER IPPool
    The StaticIPAddressPool object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$IPPool
    )

    $info = @{
        name = $IPPool.Name
        id = $IPPool.ID.Guid
        description = $IPPool.Description
        subnet = $IPPool.Subnet
        vlan = $IPPool.Vlan
        ip_address_range_start = $IPPool.IPAddressRangeStart
        ip_address_range_end = $IPPool.IPAddressRangeEnd
        ip_address_reserved_set = $IPPool.IPAddressReservedSet
        vip_address_set = $IPPool.VIPAddressSet
        dnssuffix = $IPPool.DNSSuffix
        dns_search_suffixes = $IPPool.DNSSearchSuffixes
        enable_netbios = $IPPool.EnableNetBIOS
        logical_network_definition = if ($IPPool.LogicalNetworkDefinition) { $IPPool.LogicalNetworkDefinition.Name } else { $null }
        vm_subnet = if ($IPPool.VMSubnet) { $IPPool.VMSubnet.Name } else { $null }
        default_gateways = $IPPool.DefaultGateways | ForEach-Object {
            @{
                address = $_.Address
                metric = $_.Metric
            }
        }
        dns_servers = $IPPool.DNSServers
        wins_servers = $IPPool.WINSServers
    }

    return $info
}

$exports = @(
    'Get-SCVMMVMNetworkInfo', 'Get-SCVMMLogicalNetworkInfo',
    'Get-SCVMMLogicalNetworkDefinitionInfo', 'Get-SCVMMLogicalSwitchInfo',
    'Get-SCVMMVMSubnetInfo', 'Get-SCVMMMACAddressPoolInfo',
    'Get-SCVMMUplinkPortProfileInfo', 'Get-SCVMMPortClassificationInfo',
    'Get-SCVMMHostNetworkAdapterInfo', 'Get-SCVMMIPPoolInfo'
)
Export-ModuleMember -Function $exports
