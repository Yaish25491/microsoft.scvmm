# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

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

$exports = @(
    'Get-SCVMMTemplateInfo', 'Get-SCVMMApplicationProfileInfo',
    'Get-SCVMMHardwareProfileInfo', 'Get-SCVMMGuestOSProfileInfo',
    'Get-SCVMMCapabilityProfileInfo', 'Get-SCVMMSQLProfileInfo',
    'Get-SCVMMLibraryShareInfo'
)
Export-ModuleMember -Function $exports
