#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_storage

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        state = @{ type = 'str'; default = 'present'; choices = @('absent', 'present') }
        file_name = @{ type = 'str' }
        size_mb = @{ type = 'int' }
        dynamic = @{ type = 'bool'; default = $true }
        fixed = @{ type = 'bool' }
        library_server = @{ type = 'str' }
        share_path = @{ type = 'str' }
        description = @{ type = 'str' }
        owner = @{ type = 'str' }
        enabled = @{ type = 'bool' }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.ModuleUtils.Legacy.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$state = $module.Params.state
$file_name = $module.Params.file_name
$size_mb = $module.Params.size_mb
$fixed = $module.Params.fixed
$library_server_name = $module.Params.library_server
$share_path = $module.Params.share_path
$description = $module.Params.description
$owner = $module.Params.owner
$enabled = $module.Params.enabled
$vmm_server = $module.Params.vmm_server

$module.Result.changed = $false

try {
    # Import SCVMM module using utility
    Import-SCVMMModule -Module $module

    $getParams = @{
        Name = $name
        ErrorAction = "SilentlyContinue"
    }
    if ($vmm_server) { $getParams.VMMServer = $vmm_server }

    $vhd = Get-SCVirtualHardDisk @getParams

    if ($vhd -is [array] -and $vhd.Count -gt 1) {
        $module.FailJson("Multiple virtual hard disks found with the name '$name'. Please be more specific.")
    }

    if ($state -eq 'present') {
        if (-not $vhd) {
            # Check mandatory params for creation
            if (-not $file_name) { $module.FailJson("file_name is required when creating a new virtual hard disk.") }
            if (-not $size_mb) { $module.FailJson("size_mb is required when creating a new virtual hard disk.") }
            if (-not $library_server_name) { $module.FailJson("library_server is required when creating a new virtual hard disk.") }
            if (-not $share_path) { $module.FailJson("share_path is required when creating a new virtual hard disk.") }

            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                $createParams = @{
                    Name = $name
                    FileName = $file_name
                    Size = $size_mb
                    SharePath = $share_path
                    ErrorAction = "Stop"
                }
                if ($vmm_server) { $createParams.VMMServer = $vmm_server }
                if ($description) { $createParams.Description = $description }
                if ($owner) { $createParams.Owner = $owner }
                if ($null -ne $enabled) { $createParams.Enabled = $enabled }

                if ($fixed) {
                    $createParams.Fixed = $true
                }
                else {
                    $createParams.Dynamic = $true
                }

                $libParams = @{ Name = $library_server_name; ErrorAction = "Stop" }
                if ($vmm_server) { $libParams.VMMServer = $vmm_server }
                $libServer = Get-SCLibraryServer @libParams
                if (-not $libServer) { $module.FailJson("Library server '$library_server_name' not found.") }
                $createParams.LibraryServer = $libServer

                $vhd = New-SCVirtualHardDisk @createParams
            }
        }
        else {
            # Update existing VHD
            $updateParams = @{ VirtualHardDisk = $vhd; ErrorAction = "Stop" }
            $needsUpdate = $false

            if ($null -ne $description -and $vhd.Description -ne $description) {
                $updateParams.Description = $description
                $needsUpdate = $true
            }
            if ($null -ne $owner -and $vhd.Owner -ne $owner) {
                $updateParams.Owner = $owner
                $needsUpdate = $true
            }
            if ($null -ne $enabled -and $vhd.Enabled -ne $enabled) {
                $updateParams.Enabled = $enabled
                $needsUpdate = $true
            }

            if ($needsUpdate) {
                $module.Result.changed = $true
                if (-not $module.CheckMode) {
                    $vhd = Set-SCVirtualHardDisk @updateParams
                }
            }
        }
    }
    elseif ($state -eq 'absent') {
        if ($vhd) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                Remove-SCVirtualHardDisk -VirtualHardDisk $vhd -Confirm:$false -ErrorAction Stop
                $vhd = $null
            }
        }
    }

    if ($vhd -and $state -eq 'present') {
        $module.Result.virtual_hard_disk = Get-SCVMMVirtualHardDiskInfo -VirtualHardDisk $vhd
    }
    elseif ($module.CheckMode -and -not $vhd -and $state -eq 'present') {
        $module.Result.virtual_hard_disk = @{
            name = $name
            file_name = $file_name
            size = $size_mb * 1024 * 1024
            vhd_type = if ($fixed) { "Fixed" } else { "Dynamic" }
            description = $description
        }
    }
}
catch {
    $module.FailJson("An error occurred: $($_.Exception.Message)", $_)
}

$module.ExitJson()
