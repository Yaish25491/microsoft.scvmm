#!powershell
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_library

$ErrorActionPreference = 'Stop'

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        state = @{ type = 'str'; default = 'present'; choices = @('absent', 'present') }
        description = @{ type = 'str' }
        capability_type = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$state = $module.Params.state
$description = $module.Params.description
$capability_type = $module.Params.capability_type

$module.Result.changed = $false

try {
    $capProfile = Get-SCCapabilityProfile -Name $name -ErrorAction SilentlyContinue

    if ($state -eq 'present') {
        if (-not $capProfile) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                if (-not $capability_type) {
                    $module.FailJson("capability_type is required when creating a new capability profile.")
                }
                $params = @{
                    Name = $name
                    CapabilityType = $capability_type
                }
                if ($null -ne $description) {
                    $params.Description = $description
                }
                $capProfile = New-SCCapabilityProfile @params -ErrorAction Stop
            }
        }
        else {
            $needsUpdate = $false
            $params = @{
                CapabilityProfile = $capProfile
            }

            if ($null -ne $description -and $capProfile.Description -ne $description) {
                $params.Description = $description
                $needsUpdate = $true
            }

            if ($null -ne $capability_type -and $capProfile.CapabilityType.ToString() -ne $capability_type) {
                $global:Error.Clear()
                $module.FailJson("CapabilityType cannot be changed for an existing capability profile.")
            }

            if ($needsUpdate) {
                $module.Result.changed = $true
                if (-not $module.CheckMode) {
                    $capProfile = Set-SCCapabilityProfile @params -ErrorAction Stop
                }
            }
        }

        if ($capProfile -and -not $module.CheckMode) {
            $module.Result.capability_profile = Get-SCVMMCapabilityProfileInfo -CapabilityProfile $capProfile
        }
    }
    elseif ($state -eq 'absent') {
        if ($capProfile) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                Remove-SCCapabilityProfile -CapabilityProfile $capProfile -ErrorAction Stop
                $capProfile = $null
            }
        }
    }
}
catch {
    $global:Error.Clear()
    $module.FailJson("Failed to manage capability profile: $($_.Exception.Message)", $_)
}

$module.ExitJson()
