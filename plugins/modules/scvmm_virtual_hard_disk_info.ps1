#!powershell
# Copyright (c) 2026, Ansible Cloud Team (@ansible)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm

$spec = @{
    options = @{
        name = @{ type = 'str' }
        vm_name = @{ type = 'str' }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$module.Result.changed = $false

$vmmConnection = Connect-SCVMMServerSession -Module $module -VMMServer $module.Params.vmm_server

$propertyMap = @(
    @{ Param = "id"; Property = "ID"; Type = "id" }
    @{ Param = "name"; Property = "Name"; Type = "string" }
    @{ Param = "description"; Property = "Description"; Type = "string" }
    @{ Param = "location"; Property = "Location"; Type = "string" }
    @{ Param = "directory"; Property = "Directory"; Type = "string" }
    @{ Param = "vhd_format"; Property = "VHDFormatType"; Type = "enum" }
    @{ Param = "vhd_type"; Property = "VHDType"; Type = "enum" }
    @{ Param = "size_gb"; Property = "Size"; Type = "bytes_to_gb" }
    @{ Param = "max_size_gb"; Property = "MaximumSize"; Type = "bytes_to_gb" }
    @{ Param = "enabled"; Property = "Enabled"; Type = "bool" }
    @{ Param = "is_orphaned"; Property = "IsOrphaned"; Type = "bool" }
)

$driveMap = @{}

if ($module.Params.vm_name) {
    $vm = Get-SCVMMVirtualMachine -Module $module -VMMConnection $vmmConnection -Name $module.Params.vm_name

    try {
        $vhds = @(Get-SCVirtualHardDisk -VM $vm -ErrorAction Stop)
    }
    catch {
        $module.FailJson("Failed to query virtual hard disks for VM '$($module.Params.vm_name)': $($_.Exception.Message)", $_)
    }

    try {
        $drives = @(Get-SCVirtualDiskDrive -VM $vm -ErrorAction Stop)
        foreach ($d in $drives) {
            if ($d.VirtualHardDisk) {
                $driveMap[$d.VirtualHardDisk.ID.ToString()] = @{
                    bus = $d.Bus
                    lun = $d.Lun
                    bus_type = if ($null -ne $d.BusType) { $d.BusType.ToString() } else { $null }
                }
            }
        }
    }
    catch {
        $module.FailJson("Failed to query disk drives for VM '$($module.Params.vm_name)': $($_.Exception.Message)", $_)
    }

    if ($module.Params.name) {
        $vhds = @($vhds | Where-Object { $_.Name -eq $module.Params.name })
    }
}
else {
    $name = $module.Params.name
    if ($name) {
        $vhds = @(Get-SCVMMObject -Module $module -VMMConnection $vmmConnection `
                -CmdletName 'Get-SCVirtualHardDisk' -Name $name `
                -ObjectType 'virtual hard disk' `
                -FilterScript { $_.Name -eq $name })
        $vhds = if ($vhds) { @($vhds) } else { @() }
    }
    else {
        try {
            $vhds = @(Get-SCVirtualHardDisk -VMMServer $vmmConnection -ErrorAction Stop)
        }
        catch {
            $module.FailJson("Failed to query virtual hard disks: $($_.Exception.Message)", $_)
        }
    }
}

$module.Result.virtual_hard_disks = @($vhds | ForEach-Object {
        $result = Get-SCVMMResultFromMap -PropertyMap $propertyMap -CurrentObject $_
        $result.library_server = if ($_.LibraryServer) { $_.LibraryServer.Name } else { $null }
        $result.vm_name = if ($module.Params.vm_name) { $module.Params.vm_name } else { $null }

        $vhdId = $_.ID.ToString()
        if ($driveMap.ContainsKey($vhdId)) {
            $result.bus = $driveMap[$vhdId].bus
            $result.lun = $driveMap[$vhdId].lun
            $result.bus_type = $driveMap[$vhdId].bus_type
        }
        else {
            $result.bus = $null
            $result.lun = $null
            $result.bus_type = $null
        }

        $result
    })

$module.ExitJson()
