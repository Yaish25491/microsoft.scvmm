#!powershell
#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        vmm_server = @{ type = 'str'; required = $true }
        state = @{ type = 'str'; required = $true; choices = @('started', 'stopped', 'suspended') }
        force = @{ type = 'bool'; default = $false }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$vmm_server = $module.Params.vmm_server
$state = $module.Params.state
$force = $module.Params.force

$module.Result.vm_name = $name
$module.Result.state = $null

try {
    # Import SCVMM module using utility
    Import-SCVMMModule -Module $module

    # Get the VM
    $vm = Get-SCVirtualMachine -Name $name -VMMServer $vmm_server -ErrorAction Stop
    
    if (-not $vm) {
        $module.FailJson("Virtual machine '$name' was not found on VMM server '$vmm_server'.")
    }

    # Extract single VM if multiple are returned (shouldn't happen with exact name, but just in case)
    if ($vm.Count -gt 1) {
        $module.FailJson("Multiple virtual machines found with the name '$name'. Please be more specific.")
    }

    $current_status = $vm.Status.ToString()
    $module.Result.state = $current_status

    $changed = $false

    if ($state -eq 'started') {
        if ($current_status -ne 'Running') {
            $changed = $true
            if (-not $module.CheckMode) {
                if ($current_status -eq 'Paused') {
                    Resume-SCVirtualMachine -VM $vm -ErrorAction Stop | Out-Null
                } elseif ($current_status -eq 'SavedState') {
                    Start-SCVirtualMachine -VM $vm -ErrorAction Stop | Out-Null
                } else {
                    Start-SCVirtualMachine -VM $vm -ErrorAction Stop | Out-Null
                }
                $vm = Get-SCVirtualMachine -Name $name -VMMServer $vmm_server -ErrorAction Stop
                $module.Result.state = $vm.Status.ToString()
            } else {
                $module.Result.state = 'Running'
            }
        }
    } elseif ($state -eq 'stopped') {
        if ($current_status -eq 'Running' -or $current_status -eq 'Paused' -or $current_status -eq 'SavedState') {
            $changed = $true
            if (-not $module.CheckMode) {
                if ($force) {
                    Stop-SCVirtualMachine -VM $vm -Force -ErrorAction Stop | Out-Null
                } else {
                    Stop-SCVirtualMachine -VM $vm -Shutdown -ErrorAction Stop | Out-Null
                }
                $vm = Get-SCVirtualMachine -Name $name -VMMServer $vmm_server -ErrorAction Stop
                $module.Result.state = $vm.Status.ToString()
            } else {
                $module.Result.state = 'PowerOff'
            }
        }
    } elseif ($state -eq 'suspended') {
        if ($current_status -eq 'Running') {
            $changed = $true
            if (-not $module.CheckMode) {
                Suspend-SCVirtualMachine -VM $vm -ErrorAction Stop | Out-Null
                $vm = Get-SCVirtualMachine -Name $name -VMMServer $vmm_server -ErrorAction Stop
                $module.Result.state = $vm.Status.ToString()
            } else {
                $module.Result.state = 'Paused'
            }
        } elseif ($current_status -ne 'Paused') {
            $module.FailJson("Virtual machine must be in 'Running' state to be suspended. Current state is '$current_status'.")
        }
    }

    $module.Result.changed = $changed
} catch {
    $module.FailJson("An error occurred: $_", $_)
}

$module.ExitJson()
