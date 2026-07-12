#!powershell
# Copyright (c) 2026, Ansible Cloud Team (@ansible)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        description = @{ type = 'str' }
        enabled = @{ type = 'bool' }
        state = @{
            type = 'str'
            default = 'present'
            choices = @('present', 'absent')
        }
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

$updateMap = @(
    @{ Param = "description"; Property = "Description"; Type = "string" }
    @{ Param = "enabled"; Property = "Enabled"; Type = "bool" }
)

$name = $module.Params.name
$vhd = Get-SCVMMObject -Module $module -VMMConnection $vmmConnection `
    -CmdletName 'Get-SCVirtualHardDisk' -Name $name `
    -ObjectType 'virtual hard disk' `
    -FilterScript { $_.Name -eq $name }

if ($module.Params.state -eq 'present') {
    if (-not $vhd) {
        $module.FailJson("Virtual hard disk '$name' not found. VHDs are created as part of VM or template operations.")
    }

    if (Test-SCVMMPropertiesChanged -PropertyMap $updateMap -CurrentObject $vhd -AnsibleParams $module.Params) {
        $module.Result.changed = $true
        if (-not $module.CheckMode) {
            $setParams = Get-SCVMMParametersFromMap -PropertyMap $updateMap -AnsibleParams $module.Params
            $setParams['VirtualHardDisk'] = $vhd
            $setParams['ErrorAction'] = 'Stop'
            try {
                $vhd = Set-SCVirtualHardDisk @setParams
            }
            catch {
                $module.FailJson("Failed to update virtual hard disk '$name': $($_.Exception.Message)", $_)
            }
        }
    }

    $result = Get-SCVMMResultFromMap -PropertyMap $propertyMap -CurrentObject $vhd
    $result.library_server = if ($vhd.LibraryServer) { $vhd.LibraryServer.Name } else { $null }
    $module.Result.virtual_hard_disk = $result
}
else {
    if ($vhd) {
        $module.Result.changed = $true
        if (-not $module.CheckMode) {
            try {
                Remove-SCVirtualHardDisk -VirtualHardDisk $vhd -Force -ErrorAction Stop | Out-Null
            }
            catch {
                $module.FailJson("Failed to remove virtual hard disk '$name': $($_.Exception.Message)", $_)
            }
        }
    }
}

$module.ExitJson()
