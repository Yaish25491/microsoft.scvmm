# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy

function Import-SCVMMModule {
    <#
    .SYNOPSIS
    Imports the VirtualMachineManager module.
    .DESCRIPTION
    Checks if the VirtualMachineManager module is available and imports it. Fails the Ansible module if not found.
    .PARAMETER Module
    The Ansible module object used for failing the execution if the module is not found.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification = 'Standard Ansible utility naming')]
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Module
    )

    if (-not (Get-Module -Name VirtualMachineManager -ListAvailable)) {
        $Module.FailJson("The VirtualMachineManager PowerShell module is not installed or available.")
    }

    try {
        Import-Module -Name VirtualMachineManager -ErrorAction Stop
    }
    catch {
        $Module.FailJson("Failed to import VirtualMachineManager module: $($_.Exception.Message)")
    }
}

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

function Get-SCVMMCloudInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Cloud object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a Cloud object and returns a standardized hashtable.
    .PARAMETER Cloud
    The SCCloud object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Cloud
    )

    $info = @{
        name = $Cloud.Name
        id = $Cloud.ID.Guid
        description = $Cloud.Description
        host_groups = $Cloud.VMHostGroups | ForEach-Object { $_.Name }
        read_only_library_shares = $Cloud.ReadOnlyLibraryShares | ForEach-Object { $_.Path }
        read_write_library_path = $Cloud.ReadWriteLibraryPath
        capability_profiles = $Cloud.CapabilityProfiles | ForEach-Object { $_.Name }
    }

    return $info
}

function Get-SCVMMTemplateInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Template object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a VMTemplate object and returns a standardized hashtable.
    .PARAMETER Template
    The SCVMTemplate object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Template
    )

    $info = @{
        name = $Template.Name
        id = $Template.ID.Guid
        description = $Template.Description
        owner = $Template.Owner
        cpu_count = $Template.CPUCount
        memory = $Template.Memory
        operating_system = if ($Template.OperatingSystem) { $Template.OperatingSystem.Name } else { $null }
        library_server = if ($Template.LibraryServer) { $Template.LibraryServer.Name } else { $null }
    }

    return $info
}

function Get-SCVMMHostInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM VM Host object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a Host object and returns a standardized hashtable.
    .PARAMETER VMHost
    The SCVMHost object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$VMHost
    )

    $info = @{
        name = $VMHost.Name
        id = $VMHost.ID.Guid
        description = $VMHost.Description
        host_group = if ($VMHost.VMHostGroup) { $VMHost.VMHostGroup.Name } else { $null }
        virtualization_platform = $VMHost.VirtualizationPlatform.ToString()
        operating_system = if ($VMHost.OperatingSystem) { $VMHost.OperatingSystem.Name } else { $null }
        overall_state = $VMHost.OverallState.ToString()
        total_memory = $VMHost.TotalMemory
        available_memory = $VMHost.AvailableMemory
        cpu_count = $VMHost.CPUCount
        cpu_utilization = $VMHost.CPUUtilization
        is_connected = $VMHost.IsConnected
    }

    return $info
}

function Get-SCVMMHostClusterInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Host Cluster object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a VMHostCluster object and returns a standardized hashtable.
    .PARAMETER Cluster
    The VMHostCluster object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Cluster
    )

    $info = @{
        name = $Cluster.Name
        id = $Cluster.ID.Guid
        cluster_reserve = $Cluster.ClusterReserve
        is_over_committed = $Cluster.IsOverCommitted
        nodes = $Cluster.Nodes | ForEach-Object { $_.Name }
        vm_host_group = if ($Cluster.VMHostGroup) { $Cluster.VMHostGroup.Name } else { $null }
        vm_paths = $Cluster.VMPaths
        remote_connect_enabled = $Cluster.RemoteConnectEnabled
        remote_connect_port = $Cluster.RemoteConnectPort
        virtualization_platform = if ($Cluster.VirtualizationPlatform) { $Cluster.VirtualizationPlatform.ToString() } else { $null }
    }

    return $info
}

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

function Get-SCVMMLogicalSwitchExtensionInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Virtual Switch Extension object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a VirtualSwitchExtension object and returns a standardized hashtable.
    .PARAMETER Extension
    The VirtualSwitchExtension object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Extension
    )

    $info = @{
        name = $Extension.Name
        id = $Extension.ID.Guid
        description = $Extension.Description
        vendor = $Extension.Vendor
        version = $Extension.Version
        extension_type = if ($Extension.ExtensionType) { $Extension.ExtensionType.ToString() } else { $null }
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

function Get-SCVMMVirtualHardDiskInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Virtual Hard Disk object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a SCVirtualHardDisk object and returns a standardized hashtable.
    .PARAMETER VirtualHardDisk
    The SCVirtualHardDisk object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$VirtualHardDisk
    )

    $info = @{
        name = $VirtualHardDisk.Name
        id = $VirtualHardDisk.ID.Guid
        file_name = $VirtualHardDisk.FileName
        size = $VirtualHardDisk.Size
        maximum_size = $VirtualHardDisk.MaximumSize
        vhd_type = if ($VirtualHardDisk.VHDType) { $VirtualHardDisk.VHDType.ToString() } else { $null }
        host_path = $VirtualHardDisk.HostPath
        library_server = if ($VirtualHardDisk.LibraryServer) { $VirtualHardDisk.LibraryServer.Name } else { $null }
        operating_system = if ($VirtualHardDisk.OperatingSystem) { $VirtualHardDisk.OperatingSystem.Name } else { $null }
        enabled = $VirtualHardDisk.Enabled
        description = $VirtualHardDisk.Description
        owner = $VirtualHardDisk.Owner
        virtualization_platform = if ($VirtualHardDisk.VirtualizationPlatform) { $VirtualHardDisk.VirtualizationPlatform.ToString() } else { $null }
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
        lbfo_load_balancing_algorithm = if ($UplinkPortProfile.LBFOLoadBalancingAlgorithm) { $UplinkPortProfile.LBFOLoadBalancingAlgorithm.ToString() } else { $null }
        lbfo_teaming_mode = if ($UplinkPortProfile.LBFOTeamingMode) { $UplinkPortProfile.LBFOTeamingMode.ToString() } else { $null }
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

# Export functions
Export-ModuleMember -Function Import-SCVMMModule, Get-SCVMMVMInfo, Get-SCVMMCloudInfo, Get-SCVMMTemplateInfo, Get-SCVMMHostClusterInfo, Get-SCVMMHostInfo, Get-SCVMMVMNetworkInfo, Get-SCVMMLogicalNetworkInfo, Get-SCVMMLogicalNetworkDefinitionInfo, Get-SCVMMLogicalSwitchInfo, Get-SCVMMLogicalSwitchExtensionInfo, Get-SCVMMVMSubnetInfo, Get-SCVMMVirtualHardDiskInfo, Get-SCVMMMACAddressPoolInfo, Get-SCVMMUplinkPortProfileInfo, Get-SCVMMPortClassificationInfo, Get-SCVMMHostNetworkAdapterInfo
