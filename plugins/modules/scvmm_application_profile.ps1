#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module Ansible.ModuleUtils.SCVMM

$ErrorActionPreference = 'Stop'

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        description = @{ type = 'str' }
        compatibility_v3 = @{ type = 'bool' }
        owner = @{ type = 'str' }
        user_role = @{ type = 'str' }
        state = @{ type = 'str'; choices = @('present', 'absent'); default = 'present' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$description = $module.Params.description
$compatibility_v3 = $module.Params.compatibility_v3
$owner = $module.Params.owner
$user_role_name = $module.Params.user_role
$state = $module.Params.state

$changed = $false

try {
    # Check if the application profile already exists
    $appProfile = Get-SCApplicationProfile -Name $name -ErrorAction Ignore | Select-Object -First 1

    if ($state -eq 'absent') {
        if ($appProfile) {
            $changed = $true
            if (-not $module.CheckMode) {
                Remove-SCApplicationProfile -ApplicationProfile $appProfile -ErrorAction Stop
            }
        }
    }
    elseif ($state -eq 'present') {
        $userRoleObj = $null
        if ($null -ne $user_role_name) {
            $userRoleObj = Get-SCUserRole -Name $user_role_name -ErrorAction Ignore
            if (-not $userRoleObj) {
                $global:Error.Clear()
                $module.FailJson("User role '$user_role_name' not found.")
            }
        }

        if (-not $appProfile) {
            $changed = $true
            if (-not $module.CheckMode) {
                $params = @{
                    Name = $name
                }
                if ($null -ne $description) {
                    $params.Description = $description
                }
                if ($null -ne $compatibility_v3 -and $compatibility_v3) {
                    $params.CompatibilityV3 = $true
                }
                if ($null -ne $owner) {
                    $params.Owner = $owner
                }
                if ($null -ne $userRoleObj) {
                    $params.UserRole = $userRoleObj
                }

                $appProfile = New-SCApplicationProfile @params -ErrorAction Stop
            }
        }
        else {
            $params = @{}
            if ($null -ne $description -and $appProfile.Description -ne $description) {
                $params.Description = $description
            }
            if ($null -ne $owner -and $appProfile.Owner -ne $owner) {
                $params.Owner = $owner
            }
            if ($null -ne $userRoleObj -and ($appProfile.UserRole.Name -ne $user_role_name)) {
                $params.UserRole = $userRoleObj
            }

            # Note: CompatibilityV3 cannot be modified via Set-SCApplicationProfile directly in standard cmdlets.
            if ($null -ne $compatibility_v3 -and $appProfile.CompatibilityV3 -ne $compatibility_v3) {
                $global:Error.Clear()
                $module.FailJson("The compatibility_v3 parameter cannot be modified on an existing application profile.")
            }

            if ($params.Count -gt 0) {
                $changed = $true
                if (-not $module.CheckMode) {
                    $params.ApplicationProfile = $appProfile
                    $appProfile = Set-SCApplicationProfile @params -ErrorAction Stop
                }
            }
        }

        if ($appProfile -and -not $module.CheckMode) {
            $module.Result.application_profile = Get-SCVMMApplicationProfileInfo -ApplicationProfile $appProfile
        }
    }
}
catch {
    $global:Error.Clear()
    $module.FailJson("Failed to manage application profile '$name': $($_.Exception.Message)")
}

$module.Result.changed = $changed
$module.ExitJson()
