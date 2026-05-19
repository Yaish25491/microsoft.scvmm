#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm_compliance

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        description = @{ type = 'str' }
        state = @{ type = 'str'; default = 'present'; choices = @('absent', 'present') }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$description = $module.Params.description
$state = $module.Params.state
$vmm_server = $module.Params.vmm_server

try {
    $getParams = @{ Name = $name; ErrorAction = "SilentlyContinue" }
    if ($vmm_server) { $getParams.VMMServer = $vmm_server }
    $computerProfile = Get-SCPhysicalComputerProfile @getParams

    if ($state -eq 'present') {
        if (-not $computerProfile) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                # New-SCPhysicalComputerProfile requires additional parameters
                $module.FailJson(
                    "Creation of a new Physical Computer Profile requires " +
                    "more complex parameters not yet exposed in this basic module."
                )
            }
        }
        else {
            if ($null -ne $description -and $computerProfile.Description -ne $description) {
                $module.Result.changed = $true
                if (-not $module.CheckMode) {
                    $computerProfile = Set-SCPhysicalComputerProfile -PhysicalComputerProfile $computerProfile -Description $description -ErrorAction Stop
                }
            }
        }
    }
    elseif ($state -eq 'absent') {
        if ($computerProfile) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                Remove-SCPhysicalComputerProfile -PhysicalComputerProfile $computerProfile -Force -ErrorAction Stop
                $computerProfile = $null
            }
        }
    }

    if ($computerProfile) {
        $module.Result.physical_computer_profile = Get-SCPhysicalComputerProfileInfo -PhysicalComputerProfile $computerProfile
    }
}
catch {
    $module.FailJson("Failed to manage physical computer profile: $($_.Exception.Message)", $_)
}

$module.ExitJson()
