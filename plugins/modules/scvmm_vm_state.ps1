#!powershell

# Copyright: (c) 2026, Ansible Cloud Team (@ansible)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        state = @{ type = 'str'; required = $true; choices = @('started', 'stopped', 'suspended', 'saved') }
        vmm_server = @{ type = 'str'; required = $false }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$state = $module.Params.state
$vmmServer = $module.Params.vmm_server

# Connect to SCVMM server
$vmmConnection = Connect-SCVMMServerSession -VMMServer $vmmServer -Module $module

try {
    # Get the virtual machine
    $vm = Get-SCVirtualMachine -VMMServer $vmmConnection -Name $name -ErrorAction SilentlyContinue

    if (-not $vm) {
        $module.FailJson("Virtual machine '$name' not found")
    }

    # Get current VM status
    $currentStatus = $vm.Status.ToString()

    # Map desired state to SCVMM status
    $statusMap = @{
        'started' = 'Running'
        'stopped' = 'PowerOff'
        'suspended' = 'Paused'
        'saved' = 'Saved'
    }

    $desiredStatus = $statusMap[$state]

    # Set up diff mode
    $module.Diff.before = @{ state = $currentStatus }
    $module.Diff.after = @{ state = $desiredStatus }

    # Check if state change is needed
    if ($currentStatus -eq $desiredStatus) {
        $module.Result.name = $name
        $module.Result.state = $currentStatus
        $module.Result.changed = $false
        $module.ExitJson()
    }

    # If in check mode, report what would change
    if ($module.CheckMode) {
        $module.Result.name = $name
        $module.Result.state = $desiredStatus
        $module.Result.previous_state = $currentStatus
        $module.Result.changed = $true
        $module.ExitJson()
    }

    # Execute state change based on desired state
    try {
        switch ($state) {
            'started' {
                if ($currentStatus -in @('Paused', 'Saved')) {
                    Resume-SCVirtualMachine -VM $vm -ErrorAction Stop | Out-Null
                }
                else {
                    Start-SCVirtualMachine -VM $vm -ErrorAction Stop | Out-Null
                }
            }
            'stopped' {
                Stop-SCVirtualMachine -VM $vm -Force -ErrorAction Stop | Out-Null
            }
            'suspended' {
                Suspend-SCVirtualMachine -VM $vm -ErrorAction Stop | Out-Null
            }
            'saved' {
                Save-SCVirtualMachine -VM $vm -ErrorAction Stop | Out-Null
            }
        }

        # Refresh VM object to get updated status
        $vm = Get-SCVirtualMachine -VMMServer $vmmConnection -Name $name
        $newStatus = $vm.Status.ToString()

        $module.Result.name = $name
        $module.Result.state = $newStatus
        $module.Result.previous_state = $currentStatus
        $module.Result.changed = $true

    }
    catch {
        $module.FailJson("Failed to change VM state: $($_.Exception.Message)", $_)
    }

    $module.ExitJson()

}
catch {
    $module.FailJson("An error occurred: $($_.Exception.Message)", $_)
}
