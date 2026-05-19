#!powershell

# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm_library

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        description = @{ type = 'str' }
        owner = @{ type = 'str' }
        user_role = @{ type = 'str' }
        state = @{ type = 'str'; choices = @('absent', 'present'); default = 'present' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$description = $module.Params.description
$owner = $module.Params.owner
$user_role = $module.Params.user_role
$state = $module.Params.state

try {
    $global:Error.Clear()

    # Get the existing profile
    $sqlProfile = Get-SCSQLProfile -Name $name -ErrorAction Ignore
    $userRoleObj = $null

    if ($null -ne $user_role) {
        $userRoleObj = Get-SCUserRole -Name $user_role -ErrorAction Ignore
        if (-not $userRoleObj) {
            $module.FailJson("User role '$user_role' was not found.")
        }
    }

    if ($state -eq 'absent') {
        if ($sqlProfile) {
            if (-not $module.CheckMode) {
                Remove-SCSQLProfile -SQLProfile $sqlProfile -ErrorAction Stop
            }
            $module.Result.changed = $true
        }
    }
    elseif ($state -eq 'present') {
        if (-not $sqlProfile) {
            $newParams = @{
                Name = $name
                ErrorAction = 'Stop'
            }

            if ($null -ne $description) { $newParams.Description = $description }
            if ($null -ne $owner) { $newParams.Owner = $owner }
            if ($null -ne $userRoleObj) { $newParams.UserRole = $userRoleObj }

            if (-not $module.CheckMode) {
                $sqlProfile = New-SCSQLProfile @newParams
            }
            $module.Result.changed = $true
        }
        else {
            $setParams = @{}

            if ($null -ne $description -and $sqlProfile.Description -ne $description) {
                $setParams.Description = $description
            }
            if ($null -ne $owner -and $sqlProfile.Owner -ne $owner) {
                $setParams.Owner = $owner
            }
            if ($null -ne $user_role -and $sqlProfile.UserRole.Name -ne $user_role) {
                $setParams.UserRole = $userRoleObj
            }

            if ($setParams.Count -gt 0) {
                $setParams.SQLProfile = $sqlProfile
                $setParams.ErrorAction = 'Stop'

                if (-not $module.CheckMode) {
                    $sqlProfile = Set-SCSQLProfile @setParams
                }
                $module.Result.changed = $true
            }
        }
    }

    if ($sqlProfile -and $state -eq 'present') {
        if ($module.CheckMode -and $module.Result.changed) {
            # In check mode, if we created it, we can't reliably read properties, return minimal
            if (-not (Get-SCSQLProfile -Name $name -ErrorAction Ignore)) {
                $module.Result.sql_profile = @{
                    name = $name
                    description = $description
                    owner = $owner
                    user_role = $user_role
                }
            }
            else {
                $module.Result.sql_profile = Get-SCVMMSQLProfileInfo -SQLProfile $sqlProfile
            }
        }
        else {
            $module.Result.sql_profile = Get-SCVMMSQLProfileInfo -SQLProfile $sqlProfile
        }
    }

    $module.ExitJson()
}
catch {
    $module.FailJson("Failed to manage SCVMM SQL Profile: $($_.Exception.Message)", $_)
}
