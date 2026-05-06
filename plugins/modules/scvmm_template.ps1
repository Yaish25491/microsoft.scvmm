#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        state = @{ type = 'str'; default = 'present'; choices = @('absent', 'present') }
        description = @{ type = 'str' }
        owner = @{ type = 'str' }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$state = $module.Params.state
$description = $module.Params.description
$owner = $module.Params.owner
$vmm_server = $module.Params.vmm_server

$module.Result.changed = $false

try {
    if (-not (Get-Module -Name VirtualMachineManager -ListAvailable)) {
        $module.FailJson("The VirtualMachineManager PowerShell module is not installed or available.")
    }
    Import-Module -Name VirtualMachineManager -ErrorAction Stop

    $getParams = @{}
    if ($vmm_server) { $getParams.VMMServer = $vmm_server }

    $templateParams = $getParams.Clone()
    $templateParams.Name = $name
    $template = Get-SCVMTemplate @templateParams -ErrorAction SilentlyContinue

    if ($template -is [array] -and $template.Count -gt 1) {
        $module.FailJson("Multiple VM templates found with the name '$name'. Please be more specific.")
    }

    if ($state -eq 'present') {
        if (-not $template) {
            # In a real scenario, New-SCVMTemplate requires a source (-VM, -VMTemplate, or -VirtualHardDisk)
            # For this module implementation based on Jira requirements, we assume we are mostly managing existing ones
            # or the user might expect creation but we'd need more params.
            # However, to satisfy the 'present' state for a new one, we'd need source info.
            # If we don't have enough info to create, we should probably fail or inform.
            $module.FailJson("VM template '$name' not found. Creation of a new template requires a source (VM, VHD, or another template) which is not currently supported by this module's parameters.")
        } else {
            $updateParams = @{ VMTemplate = $template; ErrorAction = "Stop" }
            $needsUpdate = $false

            if ($null -ne $description -and $template.Description -ne $description) {
                $updateParams.Description = $description
                $needsUpdate = $true
            }
            if ($null -ne $owner -and $template.Owner -ne $owner) {
                $updateParams.Owner = $owner
                $needsUpdate = $true
            }

            if ($needsUpdate) {
                $module.Result.changed = $true
                if (-not $module.CheckMode) {
                    $template = Set-SCVMTemplate @updateParams
                }
            }
        }
    } elseif ($state -eq 'absent') {
        if ($template) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                Remove-SCVMTemplate -VMTemplate $template -Force -ErrorAction Stop
            }
        }
    }

    if ($template -and $state -eq 'present') {
        $module.Result.template = @{
            name = $template.Name
            id = $template.ID.Guid
            description = $template.Description
            owner = $template.Owner
        }
    }
}
catch {
    $module.FailJson("An error occurred: $($_.Exception.Message)", $_)
}

$module.ExitJson()
