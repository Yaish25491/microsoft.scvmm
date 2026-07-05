#!powershell

# Copyright: (c) 2025, Ansible Cloud Team (@ansible)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        source_vm = @{ type = 'str'; required = $true }
        vm_host = @{ type = 'str'; required = $false }
        cloud = @{ type = 'str'; required = $false }
        vmm_server = @{ type = 'str'; required = $false }
        state = @{ type = 'str'; default = 'present'; choices = @('present', 'absent') }
        description = @{ type = 'str'; required = $false }
        path = @{ type = 'str'; required = $false }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$source_vm = $module.Params.source_vm
$vm_host = $module.Params.vm_host
$cloud = $module.Params.cloud
$vmm_server = $module.Params.vmm_server
$state = $module.Params.state
$description = $module.Params.description
$path = $module.Params.path

$module.Result.name = $name
$module.Result.source_vm = $source_vm
$module.Result.state = $state
$module.Result.changed = $false

try {
    # Connect to SCVMM Server
    $vmmConnection = Connect-SCVMMServerSession -Module $module -VMMServer $vmm_server

    if ($state -eq 'present') {
        # Check if clone VM already exists
        $existingVm = Get-SCVirtualMachine -VMMServer $vmmConnection -Name $name -ErrorAction SilentlyContinue

        if ($existingVm) {
            # VM already exists, no change needed
            $module.Result.vm = @{
                id = $existingVm.ID.ToString()
                name = $existingVm.Name
                status = $existingVm.Status
                host = $existingVm.HostName
            }
        }
        else {
            # VM does not exist, proceed with cloning
            if (-not $module.CheckMode) {
                # Get source VM
                $sourceVmObject = Get-SCVirtualMachine -VMMServer $vmmConnection -Name $source_vm -ErrorAction Stop
                if (-not $sourceVmObject) {
                    $module.FailJson("Source VM '$source_vm' not found")
                }

                # Prepare clone parameters
                $cloneParams = @{
                    Name = $name
                    VM = $sourceVmObject
                    VMMServer = $vmmConnection
                }

                # Determine placement target
                $vmHostObject = $null
                if ($cloud) {
                    $cloudObject = Get-SCCloud -VMMServer $vmmConnection -Name $cloud -ErrorAction Stop
                    if (-not $cloudObject) {
                        $module.FailJson("Cloud '$cloud' not found")
                    }
                    $cloneParams['Cloud'] = $cloudObject
                }
                else {
                    if ($vm_host) {
                        $vmHostObject = Get-SCVMHost -VMMServer $vmmConnection -ComputerName $vm_host -ErrorAction Stop
                    }
                    else {
                        $vmHostObject = $sourceVmObject.VMHost
                    }
                    if (-not $vmHostObject) {
                        $module.FailJson("Could not determine target VM host for clone")
                    }
                    $cloneParams['VMHost'] = $vmHostObject

                    if ($path) {
                        $cloneParams['Path'] = $path
                    }
                    else {
                        $defaultPaths = $vmHostObject.VMPaths
                        if ($defaultPaths -and $defaultPaths.Count -gt 0) {
                            $cloneParams['Path'] = $defaultPaths[0]
                        }
                    }
                }

                if ($description) {
                    $cloneParams['Description'] = $description
                }

                # Clone the VM
                $clonedVm = New-SCVirtualMachine @cloneParams -ErrorAction Stop

                $module.Result.vm = @{
                    id = $clonedVm.ID.ToString()
                    name = $clonedVm.Name
                    status = $clonedVm.Status
                    host = $clonedVm.HostName
                }
            }
            $module.Result.changed = $true
        }
    }
    elseif ($state -eq 'absent') {
        # Check if VM exists
        $existingVm = Get-SCVirtualMachine -VMMServer $vmmConnection -Name $name -ErrorAction SilentlyContinue

        if ($existingVm) {
            # VM exists, remove it
            if (-not $module.CheckMode) {
                # Stop VM if running
                if ($existingVm.Status -eq 'Running') {
                    Stop-SCVirtualMachine -VM $existingVm -Force -ErrorAction Stop | Out-Null
                }

                # Remove VM
                Remove-SCVirtualMachine -VM $existingVm -Force -ErrorAction Stop
            }
            $module.Result.changed = $true
        }
    }
}
catch {
    $module.FailJson("Failed to clone VM: $($_.Exception.Message)", $_)
}

$module.ExitJson()
