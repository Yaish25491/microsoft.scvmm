#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        new_name = @{ type = 'str'; required = $true }
        state = @{ type = 'str'; default = 'present'; choices = @('present') }
        vm_host = @{ type = 'str' }
        cloud = @{ type = 'str' }
        path = @{ type = 'str' }
        description = @{ type = 'str' }
        vmm_server = @{ type = 'str' }
    }
    required_one_of = @(
        @('vm_host', 'cloud')
    )
    mutually_exclusive = @(
        @('vm_host', 'cloud')
    )
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$new_name = $module.Params.new_name
$state = $module.Params.state
$vm_host = $module.Params.vm_host
$cloud = $module.Params.cloud
$path = $module.Params.path
$description = $module.Params.description
$vmm_server = $module.Params.vmm_server

$module.Result.changed = $false

try {
    # Import SCVMM module using utility
    Import-SCVMMModule -Module $module

    $getParams = @{}
    if ($vmm_server) { $getParams.VMMServer = $vmm_server }

    # Check for source VM
    $sourceParams = $getParams.Clone()
    $sourceParams.Name = $name
    $sourceVM = Get-SCVirtualMachine @sourceParams -ErrorAction SilentlyContinue

    if (-not $sourceVM) {
        $module.FailJson("Source virtual machine '$name' not found.")
    }
    if ($sourceVM -is [array]) {
        $module.FailJson("Multiple source virtual machines found with name '$name'.")
    }

    # Check for target VM
    $targetParams = $getParams.Clone()
    $targetParams.Name = $new_name
    $targetVM = Get-SCVirtualMachine @targetParams -ErrorAction SilentlyContinue

    if ($targetVM -is [array]) {
        $module.FailJson("Multiple target virtual machines found with name '$new_name'.")
    }

    if ($state -eq 'present') {
        if (-not $targetVM) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                $createParams = @{
                    VM = $sourceVM
                    Name = $new_name
                    ErrorAction = "Stop"
                }
                if ($vmm_server) { $createParams.VMMServer = $vmm_server }
                if ($description) { $createParams.Description = $description }

                if ($vm_host) {
                    if (-not $path) {
                        $module.FailJson("Parameter 'path' is required when 'vm_host' is specified.")
                    }
                    $hostParams = $getParams.Clone()
                    $hostParams.ComputerName = $vm_host
                    $scHost = Get-SCVMHost @hostParams -ErrorAction Stop
                    if (-not $scHost) { $module.FailJson("Host '$vm_host' not found.") }
                    $createParams.VMHost = $scHost
                    $createParams.Path = $path
                }

                if ($cloud) {
                    $cloudParams = $getParams.Clone()
                    $cloudParams.Name = $cloud
                    $scCloud = Get-SCCloud @cloudParams -ErrorAction Stop
                    if (-not $scCloud) { $module.FailJson("Cloud '$cloud' not found.") }
                    $createParams.Cloud = $scCloud
                }

                $targetVM = New-SCVirtualMachine @createParams
            }
        } else {
            # Idempotency check: description
            if ($null -ne $description -and $targetVM.Description -ne $description) {
                $module.Result.changed = $true
                if (-not $module.CheckMode) {
                    $updateParams = @{
                        VM = $targetVM
                        Description = $description
                        ErrorAction = "Stop"
                    }
                    $targetVM = Set-SCVirtualMachine @updateParams
                }
            }
        }
    }

    if ($targetVM) {
        $module.Result.vm = @{
            name = $targetVM.Name
            id = $targetVM.ID.Guid
            status = if ($targetVM.Status) { $targetVM.Status.ToString() } else { $targetVM.StatusString }
            cpu_count = $targetVM.CPUCount
            memory = $targetVM.Memory
            description = $targetVM.Description
        }
    } elseif ($module.CheckMode -and $module.Result.changed) {
        # Estimate return values for check mode if VM doesn't exist yet
        $module.Result.vm = @{
            name = $new_name
            status = "PowerOff"
            cpu_count = $sourceVM.CPUCount
            memory = $sourceVM.Memory
            description = $description
        }
    }
}
catch {
    $module.FailJson("An error occurred: $($_.Exception.Message)", $_)
}

$module.ExitJson()
