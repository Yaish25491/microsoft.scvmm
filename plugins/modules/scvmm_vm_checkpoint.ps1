#!powershell

# Copyright: (c) 2025, Ansible Cloud Team (@ansible)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm

$spec = @{
    options = @{
        vm_name = @{ type = 'str'; required = $true }
        name = @{ type = 'str'; required = $true }
        state = @{ type = 'str'; default = 'present'; choices = 'present', 'absent', 'reverted' }
        vmm_server = @{ type = 'str' }
        description = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$vm_name = $module.Params.vm_name
$name = $module.Params.name
$state = $module.Params.state
$vmm_server = $module.Params.vmm_server
$description = $module.Params.description

$module.Result.name = $name
$module.Result.vm_name = $vm_name
$module.Result.state = $state

try {
    # Connect to SCVMM server
    $vmmConnection = Connect-SCVMMServerSession -VMMServer $vmm_server -Module $module

    # Get the virtual machine
    $vm = Get-SCVirtualMachine -VMMServer $vmmConnection -Name $vm_name -ErrorAction SilentlyContinue
    if (-not $vm) {
        $module.FailJson("Virtual machine '$vm_name' not found")
    }

    # Get existing checkpoint if it exists
    $checkpoint = Get-SCVMCheckpoint -VM $vm -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -eq $name }

    switch ($state) {
        'present' {
            if (-not $checkpoint) {
                if (-not $module.CheckMode) {
                    $checkpointParams = @{
                        VM = $vm
                        Name = $name
                    }
                    if ($description) {
                        $checkpointParams.Description = $description
                    }
                    $checkpoint = New-SCVMCheckpoint @checkpointParams
                }
                $module.Result.changed = $true
            }

            if ($checkpoint) {
                $module.Result.checkpoint = @{
                    id = $checkpoint.CheckpointID.ToString()
                    creation_time = $checkpoint.AddedTime.ToString('o')
                    description = $checkpoint.Description
                }
            }
        }
        'absent' {
            if ($checkpoint) {
                if (-not $module.CheckMode) {
                    Remove-SCVMCheckpoint -VMCheckpoint $checkpoint -Confirm:$false
                }
                $module.Result.changed = $true
            }
        }
        'reverted' {
            if (-not $checkpoint) {
                $module.FailJson("Checkpoint '$name' not found on VM '$vm_name'. Cannot revert to non-existent checkpoint.")
            }

            if (-not $module.CheckMode) {
                Restore-SCVMCheckpoint -VMCheckpoint $checkpoint
            }
            $module.Result.changed = $true

            if ($checkpoint) {
                $module.Result.checkpoint = @{
                    id = $checkpoint.CheckpointID.ToString()
                    creation_time = $checkpoint.AddedTime.ToString('o')
                    description = $checkpoint.Description
                }
            }
        }
    }
}
catch {
    $module.FailJson("Failed to manage checkpoint: $($_.Exception.Message)", $_)
}

$module.ExitJson()
