#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        user_role_profile = @{ type = 'str'; choices = @('Administrator', 'DelegatedAdmin', 'TenantAdmin', 'SelfServiceUser', 'ReadWriteUser', 'ReadOnlyUser') }
        parent_user_role = @{ type = 'str' }
        description = @{ type = 'str' }
        members = @{ type = 'list'; elements = 'str' }
        add_member = @{ type = 'list'; elements = 'str' }
        remove_member = @{ type = 'list'; elements = 'str' }
        state = @{ type = 'str'; default = 'present'; choices = @('absent', 'present') }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$role_profile = $module.Params.user_role_profile
$parent_user_role = $module.Params.parent_user_role
$description = $module.Params.description
$members = $module.Params.members
$add_member = $module.Params.add_member
$remove_member = $module.Params.remove_member
$state = $module.Params.state
$vmm_server = $module.Params.vmm_server

try {
    $getParams = @{ Name = $name; ErrorAction = "SilentlyContinue" }
    if ($vmm_server) { $getParams.VMMServer = $vmm_server }

    $role = Get-SCUserRole @getParams

    if ($state -eq 'present') {
        if (-not $role) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                if (-not $role_profile) {
                    $module.FailJson("user_role_profile is required when creating a new user role.")
                }

                $createParams = @{
                    Name = $name
                    UserRoleProfile = $role_profile
                    ErrorAction = "Stop"
                }

                if ($description) { $createParams.Description = $description }
                if ($vmm_server) { $createParams.VMMServer = $vmm_server }

                if ($parent_user_role) {
                    $parentRole = Get-SCUserRole -Name $parent_user_role -ErrorAction SilentlyContinue
                    if (-not $parentRole) { $module.FailJson("Parent User Role '$parent_user_role' not found.") }
                    $createParams.ParentUserRole = $parentRole
                }

                $role = New-SCUserRole @createParams

                if ($members -or $add_member) {
                    $all_adds = @()
                    if ($members) { $all_adds += $members }
                    if ($add_member) { $all_adds += $add_member }
                    if ($all_adds.Count -gt 0) {
                        Set-SCUserRole -UserRole $role -AddMember $all_adds -ErrorAction Stop | Out-Null
                    }
                }
            }
        }
        else {
            $changed = $false
            $updateParams = @{ UserRole = $role; ErrorAction = "Stop" }

            if ($null -ne $description -and $role.Description -ne $description) {
                $updateParams.Description = $description
                $changed = $true
            }

            $current_members = @()
            if ($role.Users) {
                $current_members = $role.Users | ForEach-Object { $_.Name }
            }

            $to_add = @()
            $to_remove = @()

            if ($null -ne $members) {
                foreach ($m in $members) {
                    if ($m -notin $current_members) { $to_add += $m }
                }
                foreach ($cm in $current_members) {
                    if ($cm -notin $members) { $to_remove += $cm }
                }
            }
            else {
                if ($add_member) {
                    foreach ($am in $add_member) {
                        if ($am -notin $current_members) { $to_add += $am }
                    }
                }
                if ($remove_member) {
                    foreach ($rm in $remove_member) {
                        if ($rm -in $current_members) { $to_remove += $rm }
                    }
                }
            }

            if ($to_add.Count -gt 0) {
                $updateParams.AddMember = $to_add
                $changed = $true
            }
            if ($to_remove.Count -gt 0) {
                $updateParams.RemoveMember = $to_remove
                $changed = $true
            }

            if ($changed) {
                $module.Result.changed = $true
                if (-not $module.CheckMode) {
                    $role = Set-SCUserRole @updateParams
                }
            }
        }
    }
    elseif ($state -eq 'absent') {
        if ($role) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                Remove-SCUserRole -UserRole $role -Force -ErrorAction Stop
                $role = $null
            }
        }
    }

    if ($role) {
        $module.Result.user_role = Get-SCVMMUserRoleInfo -UserRole $role
    }
}
catch {
    $module.FailJson("Failed to manage user role: $($_.Exception.Message)", $_)
}

$module.ExitJson()
