#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm_compute

$spec = @{
    options = @{
        vm = @{ type = "str"; required = $true }
        bus = @{ type = "int" }
        lun = @{ type = "int" }
        iso = @{ type = "str" }
        no_media = @{ type = "bool"; default = $false }
        state = @{ type = "str"; choices = @("present", "absent"); default = "present" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$vm_name = $module.Params.vm
$bus = $module.Params.bus
$lun = $module.Params.lun
$iso_name = $module.Params.iso
$no_media = $module.Params.no_media
$state = $module.Params.state

$vm = Get-SCVirtualMachine -Name $vm_name -ErrorAction SilentlyContinue
if (-not $vm) {
    $module.FailJson("Virtual machine '$vm_name' not found.")
}

$dvd_drives = Get-SCVirtualDVDDrive -VM $vm

# Find the specific DVD drive if bus/lun provided
$target_drive = $null
if ($null -ne $bus -and $null -ne $lun) {
    $target_drive = $dvd_drives | Where-Object { $_.Bus -eq $bus -and $_.LUN -eq $lun }
}
elseif ($dvd_drives.Count -eq 1) {
    $target_drive = $dvd_drives[0]
}

function Get-DVDDriveInfo($drive) {
    if (-not $drive) { return $null }
    $info = @{
        name = $drive.Name
        id = $drive.ID.Guid
        bus = $drive.Bus
        lun = $drive.LUN
        iso = if ($drive.ISO) { $drive.ISO.Name } else { $null }
    }
    return $info
}

$result = @{
    changed = $false
    dvd_drive = Get-DVDDriveInfo($target_drive)
}

if ($state -eq "absent") {
    if ($target_drive) {
        $result.changed = $true
        if (-not $module.CheckMode) {
            try {
                Remove-SCVirtualDVDDrive -VirtualDVDDrive $target_drive -ErrorAction Stop
            }
            catch {
                $module.FailJson("Failed to remove virtual DVD drive: $($_.Exception.Message)")
            }
        }
        $result.dvd_drive = $null
    }
}
else {
    # state = present
    if (-not $target_drive) {
        if ($null -eq $bus -or $null -eq $lun) {
            $module.FailJson("Both 'bus' and 'lun' are required when creating a new virtual DVD drive.")
        }
        $result.changed = $true
        if (-not $module.CheckMode) {
            try {
                $new_drive_params = @{
                    VM = $vm
                    Bus = $bus
                    LUN = $lun
                }
                if ($iso_name) {
                    $iso = Get-SCISO -Name $iso_name -ErrorAction SilentlyContinue
                    if (-not $iso) { $module.FailJson("ISO '$iso_name' not found in SCVMM library.") }
                    $new_drive_params.ISO = $iso
                }
                $target_drive = New-SCVirtualDVDDrive @new_drive_params -ErrorAction Stop
            }
            catch {
                $module.FailJson("Failed to create virtual DVD drive: $($_.Exception.Message)")
            }
        }
    }
    else {
        # Drive exists, check for modifications
        $update_params = @{}

        if ($no_media) {
            if ($target_drive.ISO -or $target_drive.VMHostDrive) {
                $update_params.NoMedia = $true
            }
        }
        elif ($null -ne $iso_name) {
            if ($iso_name -eq "") {
                if ($target_drive.ISO -or $target_drive.VMHostDrive) {
                    $update_params.NoMedia = $true
                }
            }
            else {
                $current_iso = if ($target_drive.ISO) { $target_drive.ISO.Name } else { $null }
                if ($current_iso -ne $iso_name) {
                    $iso = Get-SCISO -Name $iso_name -ErrorAction SilentlyContinue
                    if (-not $iso) { $module.FailJson("ISO '$iso_name' not found in SCVMM library.") }
                    $update_params.ISO = $iso
                }
            }
        }

        if ($update_params.Count -gt 0) {
            $result.changed = $true
            if (-not $module.CheckMode) {
                try {
                    $target_drive = Set-SCVirtualDVDDrive -VirtualDVDDrive $target_drive @update_params -ErrorAction Stop
                }
                catch {
                    $module.FailJson("Failed to update virtual DVD drive: $($_.Exception.Message)")
                }
            }
        }
    }
    $result.dvd_drive = Get-DVDDriveInfo($target_drive)
}

$module.ExitJson($result)
