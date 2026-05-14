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

function Get-SCVMMLoadBalancerInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Load Balancer object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a LoadBalancer object and returns a standardized hashtable.
    .PARAMETER LoadBalancer
    The LoadBalancer object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$LoadBalancer
    )

    $info = @{
        name = $LoadBalancer.Name
        id = $LoadBalancer.ID.Guid
        address = $LoadBalancer.Address
        port = $LoadBalancer.Port
        manufacturer = $LoadBalancer.Manufacturer
        model = $LoadBalancer.Model
        description = $LoadBalancer.Description
        host_groups = $LoadBalancer.VMHostGroup | ForEach-Object { $_.Name }
        logical_network_vips = $LoadBalancer.LogicalNetwork | ForEach-Object { $_.Name }
        connection_state = if ($LoadBalancer.ConnectionState) { $LoadBalancer.ConnectionState.ToString() } else { $null }
        enabled = $LoadBalancer.Enabled
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

function Get-SCVMMStorageProviderInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Storage Provider object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a StorageProvider object and returns a standardized hashtable.
    .PARAMETER StorageProvider
    The StorageProvider object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$StorageProvider
    )

    $info = @{
        name = $StorageProvider.Name
        id = $StorageProvider.ID.Guid
        description = $StorageProvider.Description
        type = if ($StorageProvider.Type) { $StorageProvider.Type.ToString() } else { $null }
        network_device_name = $StorageProvider.NetworkDeviceName
        manufacturer = $StorageProvider.Manufacturer
        model = $StorageProvider.Model
        is_active = $StorageProvider.IsActive
        state = if ($StorageProvider.State) { $StorageProvider.State.ToString() } else { $null }
        tcp_port = $StorageProvider.TCPPort
    }

    return $info
}

function Get-SCVMMStorageFileShareInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Storage File Share object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a StorageFileShare object and returns a standardized hashtable.
    .PARAMETER StorageFileShare
    The StorageFileShare object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$StorageFileShare
    )

    $info = @{
        name = $StorageFileShare.Name
        id = $StorageFileShare.ID.Guid
        path = $StorageFileShare.Path
        description = $StorageFileShare.Description
        storage_classification = if ($StorageFileShare.StorageClassification) { $StorageFileShare.StorageClassification.Name } else { $null }
        capacity = $StorageFileShare.Capacity
        free_space = $StorageFileShare.FreeSpace
        is_available_for_placement = $StorageFileShare.IsAvailableForPlacement
        storage_file_server = if ($StorageFileShare.StorageFileServer) { $StorageFileShare.StorageFileServer.Name } else { $null }
        vm_host = if ($StorageFileShare.VMHost) { $StorageFileShare.VMHost.Name } else { $null }
        library_server = if ($StorageFileShare.LibraryServer) { $StorageFileShare.LibraryServer.Name } else { $null }
    }

    return $info
}

function Get-SCVMMStorageClassificationInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Storage Classification object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a StorageClassification object and returns a standardized hashtable.
    .PARAMETER StorageClassification
    The StorageClassification object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$StorageClassification
    )

    $info = @{
        name = $StorageClassification.Name
        id = $StorageClassification.ID.Guid
        description = $StorageClassification.Description
        is_read_only = $StorageClassification.IsReadOnly
        is_system = $StorageClassification.IsSystem
    }

    return $info
}

function Get-SCVMMStoragePoolInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Storage Pool object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a StoragePool object and returns a standardized hashtable.
    .PARAMETER StoragePool
    The StoragePool object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$StoragePool
    )

    $info = @{
        name = $StoragePool.Name
        id = $StoragePool.ID.Guid
        description = $StoragePool.Description
        is_managed = $StoragePool.IsManaged
        storage_classification = if ($StoragePool.StorageClassification) { $StoragePool.StorageClassification.Name } else { $null }
        storage_array = if ($StoragePool.StorageArray) { $StoragePool.StorageArray.Name } else { $null }
        total_capacity = $StoragePool.TotalCapacity
        free_space = $StoragePool.FreeSpace
        used_space = $StoragePool.UsedSpace
    }

    return $info
}

function Get-SCVMMCustomPropertyInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Custom Property object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a CustomProperty object and returns a standardized hashtable.
    .PARAMETER CustomProperty
    The CustomProperty object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$CustomProperty
    )

    $info = @{
        name = $CustomProperty.Name
        id = $CustomProperty.ID.Guid
        description = $CustomProperty.Description
        members = $CustomProperty.Members
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

function Get-SCVMMJobInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Job object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a Job object and returns a standardized hashtable.
    .PARAMETER Job
    The Task object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Job
    )

    $info = @{
        name = $Job.Name
        id = $Job.ID.Guid
        status = if ($Job.Status) { $Job.Status.ToString() } else { $null }
        description = $Job.Description
        owner = $Job.Owner
        start_time = $Job.StartTime
        end_time = $Job.EndTime
        is_cancellable = $Job.IsCancellable
        is_restartable = $Job.IsRestartable
        result_object_name = $Job.ResultObjectName
        result_object_id = if ($Job.ResultObjectID) { $Job.ResultObjectID.Guid } else { $null }
        progress = $Job.Progress
        error_code = $Job.ErrorCode
        error_summary = $Job.ErrorSummary
    }

    return $info
}

function Get-SCPXEServerInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM PXE Server object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a SCPXEServer object and returns a standardized hashtable.
    .PARAMETER PXEServer
    The SCPXEServer object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$PXEServer
    )

    $info = @{
        computer_name = $PXEServer.ComputerName
        id = $PXEServer.ID.Guid
        description = $PXEServer.Description
        is_connected = $PXEServer.IsConnected
        version = $PXEServer.Version
    }

    return $info
}

function Get-SCVMMBaselineInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Baseline object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a Baseline object and returns a standardized hashtable.
    .PARAMETER Baseline
    The SCBaseline object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Baseline
    )

    $info = @{
        name = $Baseline.Name
        id = $Baseline.ID.Guid
        description = $Baseline.Description
        updates = $Baseline.Updates | ForEach-Object {
            @{
                name = $_.Name
                id = $_.ID.Guid
                bulletin_id = $_.BulletinID
            }
        }
        assignment_scope = $Baseline.AssignmentScope | ForEach-Object {
            @{
                name = $_.Name
                id = $_.ID.Guid
                type = $_.GetType().Name
            }
        }
    }

    return $info
}

function Get-SCPhysicalComputerProfileInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Physical Computer Profile object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a PhysicalComputerProfile object and returns a standardized hashtable.
    .PARAMETER Profile
    The PhysicalComputerProfile object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Profile
    )

    $info = @{
        name = $Profile.Name
        id = $Profile.ID.Guid
        description = $Profile.Description
        owner = $Profile.Owner
        virtual_hard_disk = if ($Profile.VirtualHardDisk) { $Profile.VirtualHardDisk.Name } else { $null }
        domain = $Profile.Domain
        join_workgroup = $Profile.JoinWorkgroup
        use_as_vm_host = $Profile.UseAsVMHost
        use_as_file_server = $Profile.UseAsFileServer
        time_zone = $Profile.TimeZone
        product_key = $Profile.ProductKey
        answer_file = if ($Profile.AnswerFile) { $Profile.AnswerFile.Name } else { $null }
        gui_run_once_commands = $Profile.GuiRunOnceCommands
        driver_matching_tags = $Profile.DriverMatchingTags
        disk_configuration = $Profile.DiskConfiguration
        is_guarded = $Profile.IsGuarded
    }

    return $info
}

function Get-SCVMMUserRoleQuotaInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM User Role Quota object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a UserRoleQuota object and returns a standardized hashtable.
    .PARAMETER Quota
    The UserRoleQuota object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Quota
    )

    $info = @{
        id = $Quota.ID.Guid
        cloud = if ($Quota.Cloud) { $Quota.Cloud.Name } else { $null }
        user_role = if ($Quota.UserRole) { $Quota.UserRole.Name } else { $null }
        quota_per_user = $Quota.QuotaPerUser
        cpu_count = $Quota.CPUCount
        use_cpu_count_maximum = $Quota.UseCPUCountMaximum
        memory_mb = $Quota.MemoryMB
        use_memory_mb_maximum = $Quota.UseMemoryMBMaximum
        storage_gb = $Quota.StorageGB
        use_storage_gb_maximum = $Quota.UseStorageGBMaximum
        vm_count = $Quota.VMCount
        use_vm_count_maximum = $Quota.UseVMCountMaximum
        custom_quota_count = $Quota.CustomQuotaCount
        use_custom_quota_count_maximum = $Quota.UseCustomQuotaCountMaximum
    }

    return $info
}

function Get-SCVMMRunAsAccountInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Run As Account object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a RunAsAccount object and returns a standardized hashtable.
    .PARAMETER RunAsAccount
    The RunAsAccount object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$RunAsAccount
    )

    $info = @{
        name = $RunAsAccount.Name
        id = $RunAsAccount.ID.Guid
        description = $RunAsAccount.Description
        user_name = $RunAsAccount.UserName
        is_enabled = $RunAsAccount.IsEnabled
        owner = $RunAsAccount.Owner
    }

    return $info
}

function Get-SCVMMUserRoleInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM User Role object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a UserRole object and returns a standardized hashtable.
    .PARAMETER UserRole
    The UserRole object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$UserRole
    )

    $info = @{
        name = $UserRole.Name
        id = $UserRole.ID.Guid
        description = $UserRole.Description
        profile = if ($UserRole.Profile) { $UserRole.Profile.ToString() } else { $null }
        members = $UserRole.Members
        parent_user_role = if ($UserRole.ParentUserRole) { $UserRole.ParentUserRole.Name } else { $null }
    }

    return $info
}

function Get-SCVMMApplicationProfileInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Application Profile object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from an ApplicationProfile object and returns a standardized hashtable.
    .PARAMETER ApplicationProfile
    The ApplicationProfile object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$ApplicationProfile
    )

    $info = @{
        name = $ApplicationProfile.Name
        id = $ApplicationProfile.ID.Guid
        description = $ApplicationProfile.Description
        owner = $ApplicationProfile.Owner
        compatibility_v3 = $ApplicationProfile.CompatibilityV3
    }

    return $info
}

function Get-SCVMMHardwareProfileInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Hardware Profile object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a HardwareProfile object and returns a standardized hashtable.
    .PARAMETER HardwareProfile
    The HardwareProfile object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$HardwareProfile
    )

    $info = @{
        name = $HardwareProfile.Name
        id = $HardwareProfile.ID.Guid
        description = $HardwareProfile.Description
        owner = $HardwareProfile.Owner
        memory_mb = $HardwareProfile.MemoryMB
        cpu_count = $HardwareProfile.CPUCount
        cpu_type = if ($HardwareProfile.CPUType) { $HardwareProfile.CPUType.Name } else { $null }
        highly_available = $HardwareProfile.HighlyAvailable
        boot_order = $HardwareProfile.BootOrder
        dynamic_memory_enabled = $HardwareProfile.DynamicMemoryEnabled
        dynamic_memory_minimum_mb = $HardwareProfile.DynamicMemoryMinimumMB
        dynamic_memory_maximum_mb = $HardwareProfile.DynamicMemoryMaximumMB
        dynamic_memory_buffer_percentage = $HardwareProfile.DynamicMemoryBufferPercentage
        cpu_relative_weight = $HardwareProfile.CPURelativeWeight
        cpu_reserve = $HardwareProfile.CPUReserve
        cpu_maximum_percent = $HardwareProfile.CPUMaximumPercent
        limit_cpu_functionality = $HardwareProfile.LimitCPUFunctionality
        limit_cpu_for_migration = $HardwareProfile.LimitCPUForMigration
    }

    return $info
}

function Get-SCVMMServiceInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Service object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a Service object and returns a standardized hashtable.
    .PARAMETER Service
    The SCService object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Service
    )

    $info = @{
        name = $Service.Name
        id = $Service.ID.Guid
        description = $Service.Description
        status = if ($Service.Status) { $Service.Status.ToString() } else { $null }
        service_template = if ($Service.ServiceTemplate) { $Service.ServiceTemplate.Name } else { $null }
        user_role = if ($Service.UserRole) { $Service.UserRole.Name } else { $null }
        owner = $Service.Owner
        release = $Service.Release
        cost_center = $Service.CostCenter
        is_recoverable = $Service.IsRecoverable
    }

    return $info
}

function Get-SCVMMGuestOSProfileInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Guest OS Profile object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a GuestOSProfile object and returns a standardized hashtable.
    .PARAMETER Profile
    The GuestOSProfile object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Profile
    )

    $info = @{
        name = $Profile.Name
        id = $Profile.ID.Guid
        description = $Profile.Description
        operating_system = if ($Profile.OperatingSystem) { $Profile.OperatingSystem.Name } else { $null }
        computer_name = $Profile.ComputerName
        full_name = $Profile.FullName
        organization_name = $Profile.OrganizationName
        product_key = $Profile.ProductKey
        time_zone = $Profile.TimeZone
        gui_run_once_commands = $Profile.GuiRunOnceCommands
        domain = $Profile.Domain
        domain_admin_credential = if ($Profile.DomainAdminCredential) { $Profile.DomainAdminCredential.Name } else { $null }
        workgroup = $Profile.Workgroup
        answer_file = if ($Profile.AnswerFile) { $Profile.AnswerFile.Name } else { $null }
        linux_domain_name = $Profile.LinuxDomainName
        ssh_key = if ($Profile.SSHKey) { $Profile.SSHKey.Name } else { $null }
        owner = $Profile.Owner
        user_role = if ($Profile.UserRole) { $Profile.UserRole.Name } else { $null }
    }

    return $info
}

function Get-SCVMMCapabilityProfileInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Capability Profile object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a CapabilityProfile object and returns a standardized hashtable.
    .PARAMETER CapabilityProfile
    The CapabilityProfile object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$CapabilityProfile
    )

    $info = @{
        name = $CapabilityProfile.Name
        id = $CapabilityProfile.ID.Guid
        description = $CapabilityProfile.Description
        capability_type = if ($CapabilityProfile.CapabilityType) { $CapabilityProfile.CapabilityType.ToString() } else { $null }
    }

    return $info
}

function Get-SCVMMSQLProfileInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM SQL Profile object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a SQLProfile object and returns a standardized hashtable.
    .PARAMETER SQLProfile
    The SCSQLProfile object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$SQLProfile
    )

    $info = @{
        name = $SQLProfile.Name
        id = $SQLProfile.ID.Guid
        description = $SQLProfile.Description
        owner = $SQLProfile.Owner
        user_role = if ($SQLProfile.UserRole) { $SQLProfile.UserRole.Name } else { $null }
    }

    return $info
}

function Get-SCVMMComplianceStatusInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Compliance Status object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a ComplianceStatus object and returns a standardized hashtable.
    .PARAMETER ComplianceStatus
    The ComplianceStatus object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$ComplianceStatus
    )

    $info = @{
        compliance_status = if ($ComplianceStatus.ComplianceStatus) { $ComplianceStatus.ComplianceStatus.ToString() } else { $null }
        last_scan_time = $ComplianceStatus.LastScanTime
        object_name = if ($ComplianceStatus.ItemName) { $ComplianceStatus.ItemName } elseif ($ComplianceStatus.Name) { $ComplianceStatus.Name } else { $null }
        object_type = if ($ComplianceStatus.ItemType) { $ComplianceStatus.ItemType.ToString() } else { $null }
        baseline_name = if ($ComplianceStatus.Baseline) { $ComplianceStatus.Baseline.Name } else { $null }
        error_code = $ComplianceStatus.ErrorCode
        error_description = $ComplianceStatus.ErrorDescription
    }

    return $info
}

function Get-SCVMMISOInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM ISO object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from an ISO object and returns a standardized hashtable.
    .PARAMETER ISO
    The SCISO object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$ISO
    )

    $info = @{
        name = $ISO.Name
        id = $ISO.ID.Guid
        description = $ISO.Description
        family_name = $ISO.FamilyName
        release = $ISO.Release
        library_server = if ($ISO.LibraryServer) { $ISO.LibraryServer.Name } else { $null }
        share_path = $ISO.SharePath
        size = $ISO.Size
        is_equivalent = $ISO.IsEquivalent
        added_time = if ($ISO.AddedTime) { $ISO.AddedTime.ToString('yyyy-MM-ddTHH:mm:ssZ') } else { $null }
        modified_time = if ($ISO.ModifiedTime) { $ISO.ModifiedTime.ToString('yyyy-MM-ddTHH:mm:ssZ') } else { $null }
    }

    return $info
}

function Get-SCVMMScriptInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Script object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a Script object and returns a standardized hashtable.
    .PARAMETER Script
    The SCScript object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Script
    )

    $info = @{
        name = $Script.Name
        id = $Script.ID.Guid
        description = $Script.Description
        family_name = $Script.FamilyName
        release = $Script.Release
        library_server = if ($Script.LibraryServer) { $Script.LibraryServer.Name } else { $null }
        share_path = $Script.SharePath
        is_equivalent = $Script.IsEquivalent
        added_time = if ($Script.AddedTime) { $Script.AddedTime.ToString('yyyy-MM-ddTHH:mm:ssZ') } else { $null }
        modified_time = if ($Script.ModifiedTime) { $Script.ModifiedTime.ToString('yyyy-MM-ddTHH:mm:ssZ') } else { $null }
    }

    return $info
}

function Get-SCVMMVirtualDiskDriveInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Virtual Disk Drive object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a VirtualDiskDrive object and returns a standardized hashtable.
    .PARAMETER VirtualDiskDrive
    The VirtualDiskDrive object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$VirtualDiskDrive
    )

    $info = @{
        name = $VirtualDiskDrive.Name
        id = $VirtualDiskDrive.ID.Guid
        bus = $VirtualDiskDrive.Bus
        lun = $VirtualDiskDrive.LUN
        bus_type = if ($VirtualDiskDrive.BusType) { $VirtualDiskDrive.BusType.ToString() } else { $null }
        volume_type = if ($VirtualDiskDrive.VolumeType) { $VirtualDiskDrive.VolumeType.ToString() } else { $null }
        virtual_hard_disk = if ($VirtualDiskDrive.VirtualHardDisk) { $VirtualDiskDrive.VirtualHardDisk.Name } else { $null }
    }

    return $info
}

$exports = @(
    'Import-SCVMMModule',
    'Get-SCVMMCapabilityProfileInfo',
    'Get-SCVMMComplianceStatusInfo',
    'Get-SCVMMVirtualDiskDriveInfo',
    'Get-SCVMMVMInfo',
    'Get-SCVMMCloudInfo',
    'Get-SCVMMTemplateInfo',
    'Get-SCVMMHostClusterInfo',
    'Get-SCVMMHostInfo',
    'Get-SCVMMVMNetworkInfo',
    'Get-SCVMMLogicalNetworkInfo',
    'Get-SCVMMLogicalNetworkDefinitionInfo',
    'Get-SCVMMLogicalSwitchInfo',
    'Get-SCVMMLogicalSwitchExtensionInfo',
    'Get-SCVMMIPPoolInfo',
    'Get-SCVMMVMSubnetInfo',
    'Get-SCVMMVirtualHardDiskInfo',
    'Get-SCVMMMACAddressPoolInfo',
    'Get-SCVMMUplinkPortProfileInfo',
    'Get-SCVMMPortClassificationInfo',
    'Get-SCVMMHostNetworkAdapterInfo',
    'Get-SCVMMStorageProviderInfo',
    'Get-SCVMMStorageFileShareInfo',
    'Get-SCVMMStoragePoolInfo',
    'Get-SCVMMStorageClassificationInfo',
    'Get-SCVMMCustomPropertyInfo',
    'Get-SCVMMVirtualNetworkAdapterInfo',
    'Get-SCVMMLoadBalancerInfo',
    'Get-SCVMMJobInfo',
    'Get-SCPXEServerInfo',
    'Get-SCVMMVMCheckpointInfo',
    'Get-SCUpdateServerInfo',
    'Get-SCVMMBaselineInfo',
    'Get-SCPhysicalComputerProfileInfo',
    'Get-SCVMMUserRoleQuotaInfo',
    'Get-SCVMMUserRoleInfo',
    'Get-SCVMMRunAsAccountInfo',
    'Get-SCVMMApplicationProfileInfo',
    'Get-SCVMMHardwareProfileInfo',
    'Get-SCVMMGuestOSProfileInfo',
    'Get-SCVMMServiceInfo',
    'Get-SCVMMServiceTemplateInfo',
    'Get-SCVMMCustomResourceInfo',
    'Get-SCVMMISOInfo',
    'Get-SCVMMScriptInfo'
)
Export-ModuleMember -Function $exports

function Get-SCVMMCustomResourceInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Custom Resource object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a CustomResource object and returns a standardized hashtable.
    .PARAMETER CustomResource
    The CustomResource object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$CustomResource
    )

    $info = @{
        name = $CustomResource.Name
        id = $CustomResource.ID.Guid
        description = $CustomResource.Description
        family_name = $CustomResource.FamilyName
        release = $CustomResource.Release
        library_server = if ($CustomResource.LibraryServer) { $CustomResource.LibraryServer.Name } else { $null }
        share_path = $CustomResource.SharePath
        is_equivalent = $CustomResource.IsEquivalent
        added_time = $CustomResource.AddedTime
        modified_time = $CustomResource.ModifiedTime
    }

    return $info
}

function Get-SCVMMServiceTemplateInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Service Template object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a ServiceTemplate object and returns a standardized hashtable.
    .PARAMETER ServiceTemplate
    The ServiceTemplate object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$ServiceTemplate
    )

    $info = @{
        name = $ServiceTemplate.Name
        id = $ServiceTemplate.ID.Guid
        description = $ServiceTemplate.Description
        release = $ServiceTemplate.Release
        owner = $ServiceTemplate.Owner
        service_priority = if ($ServiceTemplate.ServicePriority) { $ServiceTemplate.ServicePriority.ToString() } else { $null }
        user_role = if ($ServiceTemplate.UserRole) { $ServiceTemplate.UserRole.Name } else { $null }
        is_published = $ServiceTemplate.Published
    }

    return $info
}

function Get-SCVMMLibraryShareInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Library Share object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a LibraryShare object and returns a standardized hashtable.
    .PARAMETER LibraryShare
    The SCLibraryShare object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$LibraryShare
    )

    $info = @{
        name = $LibraryShare.Name
        id = $LibraryShare.ID.Guid
        description = $LibraryShare.Description
        path = $LibraryShare.Path
        library_server = if ($LibraryShare.LibraryServer) { $LibraryShare.LibraryServer.Name } else { $null }
        is_read_only = $LibraryShare.IsReadOnly
    }

    return $info
}

function Get-SCVMMLibraryResourceInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Library Resource object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a LibraryResource object and returns a standardized hashtable.
    .PARAMETER LibraryResource
    The SCLibraryResource object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$LibraryResource
    )

    $info = @{
        name = $LibraryResource.Name
        id = $LibraryResource.ID.Guid
        description = $LibraryResource.Description
        library_server = if ($LibraryResource.LibraryServer) { $LibraryResource.LibraryServer.Name } else { $null }
        share_path = $LibraryResource.SharePath
    }

    return $info
}
