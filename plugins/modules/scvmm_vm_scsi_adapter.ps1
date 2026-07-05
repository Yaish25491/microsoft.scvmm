#!powershell

# Copyright: (c) 2025, Ansible Cloud Team (@ansible)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm

$spec = @{
    options = @{
        vm_name = @{ type = 'str'; required = $true }
        state = @{ type = 'str'; default = 'present'; choices = @('present', 'absent') }
        vmm_server = @{ type = 'str' }
        adapter_id = @{ type = 'int' }
        shared = @{ type = 'bool'; default = $false }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$vm_name = $module.Params.vm_name
$state = $module.Params.state
$vmm_server = $module.Params.vmm_server
$adapter_id = $module.Params.adapter_id
$shared = $module.Params.shared

$module.Result.vm_name = $vm_name
$module.Result.state = $state
$module.Result.changed = $false

try {
    # Connect to SCVMM server
    $vmmConnection = Connect-SCVMMServerSession -VMMServer $vmm_server -Module $module

    # Get the virtual machine
    $vm = Get-SCVirtualMachine -VMMServer $vmmConnection -Name $vm_name -ErrorAction Stop
    if (-not $vm) {
        $module.FailJson("Virtual machine '$vm_name' not found")
    }

    # Get existing SCSI adapters
    $adapters = Get-SCVirtualScsiAdapter -VM $vm

    # Filter by adapter_id if specified
    if ($null -ne $adapter_id) {
        $existingAdapter = $adapters | Where-Object { $_.AdapterID -eq $adapter_id } | Select-Object -First 1
    }
    else {
        $existingAdapter = $null
    }

    if ($state -eq 'present') {
        if ($null -eq $existingAdapter) {
            # Create new SCSI adapter
            if (-not $module.CheckMode) {
                $newAdapterParams = @{
                    VM = $vm
                    ShareVirtualScsiAdapter = $shared
                }

                # Add adapter_id if specified
                if ($null -ne $adapter_id) {
                    $newAdapterParams.AdapterID = $adapter_id
                }

                $newAdapter = New-SCVirtualScsiAdapter @newAdapterParams -ErrorAction Stop

                $module.Result.scsi_adapter = @{
                    id = $newAdapter.ID.ToString()
                    adapter_id = $newAdapter.AdapterID
                    shared = $newAdapter.Shared
                }
            }
            else {
                # In check mode, simulate the result
                $checkAdapterId = 0
                if ($null -ne $adapter_id) {
                    $checkAdapterId = $adapter_id
                }
                $module.Result.scsi_adapter = @{
                    id = '00000000-0000-0000-0000-000000000000'
                    adapter_id = $checkAdapterId
                    shared = $shared
                }
            }
            $module.Result.changed = $true
        }
        else {
            # Adapter exists, check if shared state needs to be updated
            if ($existingAdapter.Shared -ne $shared) {
                if (-not $module.CheckMode) {
                    $updatedAdapter = Set-SCVirtualScsiAdapter -VirtualScsiAdapter $existingAdapter -ShareVirtualScsiAdapter $shared -ErrorAction Stop

                    $module.Result.scsi_adapter = @{
                        id = $updatedAdapter.ID.ToString()
                        adapter_id = $updatedAdapter.AdapterID
                        shared = $updatedAdapter.Shared
                    }
                }
                else {
                    $module.Result.scsi_adapter = @{
                        id = $existingAdapter.ID.ToString()
                        adapter_id = $existingAdapter.AdapterID
                        shared = $shared
                    }
                }
                $module.Result.changed = $true
            }
            else {
                # No changes needed
                $module.Result.scsi_adapter = @{
                    id = $existingAdapter.ID.ToString()
                    adapter_id = $existingAdapter.AdapterID
                    shared = $existingAdapter.Shared
                }
            }
        }
    }
    elseif ($state -eq 'absent') {
        if ($null -eq $adapter_id) {
            $module.FailJson("adapter_id is required when state is absent")
        }

        if ($null -ne $existingAdapter) {
            # Remove the SCSI adapter
            if (-not $module.CheckMode) {
                Remove-SCVirtualScsiAdapter -VirtualScsiAdapter $existingAdapter -ErrorAction Stop
            }
            $module.Result.changed = $true
        }
        # If adapter doesn't exist, no change needed
    }

    $module.ExitJson()

}
catch {
    $module.FailJson("Failed to manage SCSI adapter: $($_.Exception.Message)", $_)
}
