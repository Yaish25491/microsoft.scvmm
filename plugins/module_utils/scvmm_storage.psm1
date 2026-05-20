# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

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

Export-ModuleMember -Function 'Get-SCVMMVirtualHardDiskInfo', 'Get-SCVMMStorageProviderInfo', 'Get-SCVMMStorageClassificationInfo', 'Get-SCVMMStoragePoolInfo'
