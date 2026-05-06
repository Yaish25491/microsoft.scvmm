#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        state = @{ type = 'str'; default = 'present'; choices = @('absent', 'present') }
        host_group = @{ type = 'str' }
        cloud = @{ type = 'str' }
        description = @{ type = 'str' }
        memory_mb = @{ type = 'int' }
        cpu_count = @{ type = 'int' }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$state = $module.Params.state
$host_group = $module.Params.host_group
$cloud = $module.Params.cloud
$description = $module.Params.description
$memory_mb = $module.Params.memory_mb
$cpu_count = $module.Params.cpu_count
$vmm_server = $module.Params.vmm_server

$module.Result.changed = $false

try {
    if (-not (Get-Module -Name VirtualMachineManager -ListAvailable)) {
        $module.FailJson("The VirtualMachineManager PowerShell module is not installed or available.")
    }
    Import-Module -Name VirtualMachineManager -ErrorAction Stop

    $getParams = @{}
    if ($vmm_server) { $getParams.VMMServer = $vmm_server }

    $vmParams = $getParams.Clone()
    $vmParams.Name = $name
    $vm = Get-SCVirtualMachine @vmParams -ErrorAction SilentlyContinue

    if ($vm -is [array] -and $vm.Count -gt 1) {
        $module.FailJson("Multiple virtual machines found with the name '$name'. Please be more specific.")
    }

    if ($state -eq 'present') {
        if (-not $vm) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                $createParams = @{ Name = $name; ErrorAction = "Stop" }
                if ($vmm_server) { $createParams.VMMServer = $vmm_server }
                if ($description) { $createParams.Description = $description }
                if ($memory_mb) { $createParams.MemoryMB = $memory_mb }
                if ($cpu_count) { $createParams.CPUCount = $cpu_count }

                if ($host_group) {
                    $hgParams = $getParams.Clone()
                    $hgParams.Name = $host_group
                    $hg = Get-SCVMHostGroup @hgParams -ErrorAction Stop
                    if (-not $hg) { $module.FailJson("Host group '$host_group' not found.") }
                    $createParams.VMHostGroup = $hg
                }

                if ($cloud) {
                    $cloudParams = $getParams.Clone()
                    $cloudParams.Name = $cloud
                    $scCloud = Get-SCCloud @cloudParams -ErrorAction Stop
                    if (-not $scCloud) { $module.FailJson("Cloud '$cloud' not found.") }
                    $createParams.Cloud = $scCloud
                }

                $vm = New-SCVirtualMachine @createParams
            }
        } else {
            $updateParams = @{ VM = $vm; ErrorAction = "Stop" }
            $needsUpdate = $false

            if ($null -ne $description -and $vm.Description -ne $description) {
                $updateParams.Description = $description
                $needsUpdate = $true
            }
            if ($null -ne $memory_mb -and $vm.Memory -ne $memory_mb) {
                $updateParams.MemoryMB = $memory_mb
                $needsUpdate = $true
            }
            if ($null -ne $cpu_count -and $vm.CPUCount -ne $cpu_count) {
                $updateParams.CPUCount = $cpu_count
                $needsUpdate = $true
            }

            if ($needsUpdate) {
                $module.Result.changed = $true
                if (-not $module.CheckMode) {
                    $vm = Set-SCVirtualMachine @updateParams
                }
            }
        }
    } elseif ($state -eq 'absent') {
        if ($vm) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                if ($vm.Status -eq 'Running' -or $vm.Status -eq 'Paused') {
                    Stop-SCVirtualMachine -VM $vm -Force -ErrorAction Stop | Out-Null
                }
                Remove-SCVirtualMachine -VM $vm -Force -ErrorAction Stop
            }
        }
    }

    if ($vm -and $state -eq 'present') {
        $module.Result.vm = @{
            name = $vm.Name
            id = $vm.ID.Guid
            status = if ($vm.Status) { $vm.Status.ToString() } else { $vm.StatusString }
            cpu_count = $vm.CPUCount
            memory = $vm.Memory
            description = $vm.Description
        }
    } elseif ($module.CheckMode -and -not $vm -and $state -eq 'present') {
        $module.Result.vm = @{
            name = $name
            status = "PowerOff"
            cpu_count = $cpu_count
            memory = $memory_mb
            description = $description
        }
    }
}
catch {
    $module.FailJson("An error occurred: $($_.Exception.Message)", $_)
}

$module.ExitJson()
