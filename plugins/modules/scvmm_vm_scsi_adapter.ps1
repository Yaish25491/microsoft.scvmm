#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm_compute

$spec = @{
    options = @{
        vm = @{ type = "str"; required = $true }
        adapter_id = @{ type = "int" }
        shared = @{ type = "bool" }
        synthetic = @{ type = "bool" }
        state = @{ type = "str"; choices = @("present", "absent"); default = "present" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$vm_name = $module.Params.vm
$adapter_id = $module.Params.adapter_id
$shared = $module.Params.shared
$synthetic = $module.Params.synthetic
$state = $module.Params.state

$vm = Get-SCVirtualMachine -Name $vm_name -ErrorAction SilentlyContinue
if (-not $vm) {
    $module.FailJson("Virtual machine '$vm_name' not found.")
}

$adapters = Get-SCVirtualSCSIAdapter -VM $vm

# Find the specific adapter if adapter_id provided
$target_adapter = $null
if ($null -ne $adapter_id) {
    $target_adapter = $adapters | Where-Object { $_.AdapterID -eq $adapter_id }
}

function Get-AdapterInfo($adapter) {
    if (-not $adapter) { return $null }
    $info = @{
        name = $adapter.Name
        id = $adapter.ID.Guid
        adapter_id = $adapter.AdapterID
        shared = $adapter.SharedVirtualScsiAdapter
    }
    # Synthetic property might not be available on all adapter objects depending on version/host type
    if (Get-Member -InputObject $adapter -Name "Synthetic") {
        $info.synthetic = $adapter.Synthetic
    }
    return $info
}

$result = @{
    changed = $false
    scsi_adapter = Get-AdapterInfo($target_adapter)
}

if ($state -eq "absent") {
    if ($target_adapter) {
        $result.changed = $true
        if (-not $module.CheckMode) {
            try {
                Remove-SCVirtualSCSIAdapter -VirtualScsiAdapter $target_adapter -ErrorAction Stop
            }
            catch {
                $module.FailJson("Failed to remove virtual SCSI adapter: $($_.Exception.Message)")
            }
        }
        $result.scsi_adapter = $null
    }
}
else {
    # state = present
    if (-not $target_adapter) {
        $result.changed = $true
        if (-not $module.CheckMode) {
            try {
                $new_params = @{
                    VM = $vm
                }
                if ($null -ne $adapter_id) { $new_params.AdapterID = $adapter_id }
                if ($null -ne $shared) { $new_params.SharedVirtualScsiAdapter = $shared }
                if ($null -ne $synthetic) { $new_params.Synthetic = $synthetic }

                $target_adapter = New-SCVirtualSCSIAdapter @new_params -ErrorAction Stop
            }
            catch {
                $module.FailJson("Failed to create virtual SCSI adapter: $($_.Exception.Message)")
            }
        }
    }
    else {
        # Adapter exists, check for modifications
        $update_params = @{}

        if ($null -ne $shared) {
            if ($target_adapter.SharedVirtualScsiAdapter -ne $shared) {
                $update_params.ShareVirtualScsiAdapter = $shared
            }
        }

        if ($update_params.Count -gt 0) {
            $result.changed = $true
            if (-not $module.CheckMode) {
                try {
                    $target_adapter = Set-SCVirtualSCSIAdapter -VirtualScsiAdapter $target_adapter @update_params -ErrorAction Stop
                }
                catch {
                    $module.FailJson("Failed to update virtual SCSI adapter: $($_.Exception.Message)")
                }
            }
        }
    }
    $result.scsi_adapter = Get-AdapterInfo($target_adapter)
}

$module.ExitJson($result)
