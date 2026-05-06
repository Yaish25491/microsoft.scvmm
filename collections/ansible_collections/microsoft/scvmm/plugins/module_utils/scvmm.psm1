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

# Export functions
Export-ModuleMember -Function Import-SCVMMModule, Get-SCVMMVMInfo, Get-SCVMMCloudInfo, Get-SCVMMTemplateInfo
