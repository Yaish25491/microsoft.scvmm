#!powershell
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_library

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        state = @{ type = 'str'; default = 'present'; choices = @('absent', 'present') }
        description = @{ type = 'str' }
        operating_system = @{ type = 'str' }
        computer_name = @{ type = 'str' }
        full_name = @{ type = 'str' }
        organization_name = @{ type = 'str' }
        admin_password = @{ type = 'str'; no_log = $true }
        product_key = @{ type = 'str' }
        time_zone = @{ type = 'int' }
        gui_run_once_commands = @{ type = 'list'; elements = 'str' }
        domain = @{ type = 'str' }
        domain_admin_credential = @{ type = 'str' }
        workgroup = @{ type = 'str' }
        answer_file = @{ type = 'str' }
        linux_domain_name = @{ type = 'str' }
        ssh_key = @{ type = 'str' }
        owner = @{ type = 'str' }
        user_role = @{ type = 'str' }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$state = $module.Params.state
$description = $module.Params.description
$operating_system = $module.Params.operating_system
$computer_name = $module.Params.computer_name
$full_name = $module.Params.full_name
$organization_name = $module.Params.organization_name
$admin_password = $module.Params.admin_password
$product_key = $module.Params.product_key
$time_zone = $module.Params.time_zone
$gui_run_once_commands = $module.Params.gui_run_once_commands
$domain = $module.Params.domain
$domain_admin_credential = $module.Params.domain_admin_credential
$workgroup = $module.Params.workgroup
$answer_file = $module.Params.answer_file
$linux_domain_name = $module.Params.linux_domain_name
$ssh_key = $module.Params.ssh_key
$owner = $module.Params.owner
$user_role = $module.Params.user_role
$vmm_server = $module.Params.vmm_server

$module.Result.changed = $false

function Compare-Array {
    param($array1, $array2)
    if ($null -eq $array1 -and $null -eq $array2) { return $true }
    if ($null -eq $array1 -or $null -eq $array2) { return $false }
    if ($array1.Count -ne $array2.Count) { return $false }
    for ($i = 0; $i -lt $array1.Count; $i++) {
        if ($array1[$i] -ne $array2[$i]) { return $false }
    }
    return $true
}

try {
    $getParams = @{ ErrorAction = "Stop" }
    if ($vmm_server) { $getParams.VMMServer = $vmm_server }

    $profileParams = $getParams.Clone()
    $profileParams.Name = $name
    $guestOSProfile = Get-SCGuestOSProfile @profileParams -ErrorAction SilentlyContinue

    if ($guestOSProfile -is [array] -and $guestOSProfile.Count -gt 1) {
        $module.FailJson("Multiple guest OS profiles found with the name '$name'. Please be more specific.")
    }

    if ($state -eq 'present') {
        $osObj = $null
        if ($operating_system) {
            $osParams = $getParams.Clone()
            $osParams.Name = $operating_system
            $osObj = Get-SCOperatingSystem @osParams -ErrorAction SilentlyContinue
            if (-not $osObj) { $module.FailJson("Operating system '$operating_system' not found.") }
        }

        $credObj = $null
        if ($domain_admin_credential) {
            $credParams = $getParams.Clone()
            $credParams.Name = $domain_admin_credential
            $credObj = Get-SCRunAsAccount @credParams -ErrorAction SilentlyContinue
            if (-not $credObj) { $module.FailJson("Run As Account '$domain_admin_credential' not found.") }
        }

        $answerFileObj = $null
        if ($answer_file) {
            $answerParams = $getParams.Clone()
            $answerParams.Name = $answer_file
            $answerFileObj = Get-SCScript @answerParams -ErrorAction SilentlyContinue
            if (-not $answerFileObj) { $module.FailJson("Answer file script '$answer_file' not found in library.") }
        }

        $sshKeyObj = $null
        if ($ssh_key) {
            $sshParams = $getParams.Clone()
            $sshParams.Name = $ssh_key
            $sshKeyObj = Get-SCSshKey @sshParams -ErrorAction SilentlyContinue
            if (-not $sshKeyObj) { $module.FailJson("SSH Key '$ssh_key' not found.") }
        }

        $userRoleObj = $null
        if ($user_role) {
            $roleParams = $getParams.Clone()
            $roleParams.Name = $user_role
            $userRoleObj = Get-SCUserRole @roleParams -ErrorAction SilentlyContinue
            if (-not $userRoleObj) { $module.FailJson("User Role '$user_role' not found.") }
        }

        if (-not $guestOSProfile) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                $createParams = @{ Name = $name; ErrorAction = "Stop" }
                if ($vmm_server) { $createParams.VMMServer = $vmm_server }
                if ($description) { $createParams.Description = $description }
                if ($osObj) { $createParams.OperatingSystem = $osObj }
                if ($computer_name) { $createParams.ComputerName = $computer_name }
                if ($full_name) { $createParams.FullName = $full_name }
                if ($organization_name) { $createParams.OrganizationName = $organization_name }
                if ($admin_password) { $createParams.AdminPassword = $admin_password }
                if ($product_key) { $createParams.ProductKey = $product_key }
                if ($null -ne $time_zone) { $createParams.TimeZone = $time_zone }
                if ($gui_run_once_commands) { $createParams.GuiRunOnceCommands = $gui_run_once_commands }
                if ($domain) { $createParams.Domain = $domain }
                if ($credObj) { $createParams.DomainCredential = $credObj }
                if ($workgroup) { $createParams.Workgroup = $workgroup }
                if ($answerFileObj) { $createParams.AnswerFile = $answerFileObj }
                if ($linux_domain_name) { $createParams.LinuxDomainName = $linux_domain_name }
                if ($sshKeyObj) { $createParams.LinuxAdministratorSSHKey = $sshKeyObj }
                if ($owner) { $createParams.Owner = $owner }
                if ($userRoleObj) { $createParams.UserRole = $userRoleObj }

                $guestOSProfile = New-SCGuestOSProfile @createParams
            }
        }
        else {
            $updateParams = @{ GuestOSProfile = $guestOSProfile; ErrorAction = "Stop" }
            $needsUpdate = $false

            if ($null -ne $description -and $guestOSProfile.Description -ne $description) {
                $updateParams.Description = $description
                $needsUpdate = $true
            }
            if ($osObj -and ($guestOSProfile.OperatingSystem.Name -ne $osObj.Name)) {
                $updateParams.OperatingSystem = $osObj
                $needsUpdate = $true
            }
            if ($null -ne $computer_name -and $guestOSProfile.ComputerName -ne $computer_name) {
                $updateParams.ComputerName = $computer_name
                $needsUpdate = $true
            }
            if ($null -ne $full_name -and $guestOSProfile.FullName -ne $full_name) {
                $updateParams.FullName = $full_name
                $needsUpdate = $true
            }
            if ($null -ne $organization_name -and $guestOSProfile.OrganizationName -ne $organization_name) {
                $updateParams.OrganizationName = $organization_name
                $needsUpdate = $true
            }
            if ($null -ne $admin_password) {
                $updateParams.AdminPassword = $admin_password
                $needsUpdate = $true
            }
            if ($null -ne $product_key -and $guestOSProfile.ProductKey -ne $product_key) {
                $updateParams.ProductKey = $product_key
                $needsUpdate = $true
            }
            if ($null -ne $time_zone -and $guestOSProfile.TimeZone -ne $time_zone) {
                $updateParams.TimeZone = $time_zone
                $needsUpdate = $true
            }
            if ($null -ne $gui_run_once_commands) {
                $currentCommands = if ($guestOSProfile.GuiRunOnceCommands) { @($guestOSProfile.GuiRunOnceCommands) } else { @() }
                $newCommands = @($gui_run_once_commands)
                if (-not (Compare-Array $currentCommands $newCommands)) {
                    $updateParams.GuiRunOnceCommands = $newCommands
                    $needsUpdate = $true
                }
            }
            if ($null -ne $domain -and $guestOSProfile.Domain -ne $domain) {
                $updateParams.Domain = $domain
                $needsUpdate = $true
            }
            if ($credObj -and ($guestOSProfile.DomainAdminCredential.Name -ne $credObj.Name)) {
                $updateParams.DomainAdminCredential = $credObj
                $needsUpdate = $true
            }
            if ($null -ne $workgroup -and $guestOSProfile.Workgroup -ne $workgroup) {
                $updateParams.Workgroup = $workgroup
                $needsUpdate = $true
            }
            if ($answerFileObj -and ($guestOSProfile.AnswerFile.Name -ne $answerFileObj.Name)) {
                $updateParams.AnswerFile = $answerFileObj
                $needsUpdate = $true
            }
            if ($null -ne $linux_domain_name -and $guestOSProfile.LinuxDomainName -ne $linux_domain_name) {
                $updateParams.LinuxDomainName = $linux_domain_name
                $needsUpdate = $true
            }
            if ($sshKeyObj -and ($guestOSProfile.SSHKey.Name -ne $sshKeyObj.Name)) {
                $updateParams.SSHKey = $sshKeyObj
                $needsUpdate = $true
            }
            if ($null -ne $owner -and $guestOSProfile.Owner -ne $owner) {
                $updateParams.Owner = $owner
                $needsUpdate = $true
            }
            if ($userRoleObj -and ($guestOSProfile.UserRole.Name -ne $userRoleObj.Name)) {
                $updateParams.UserRole = $userRoleObj
                $needsUpdate = $true
            }

            if ($needsUpdate) {
                $module.Result.changed = $true
                if (-not $module.CheckMode) {
                    $guestOSProfile = Set-SCGuestOSProfile @updateParams
                }
            }
        }
    }
    elseif ($state -eq 'absent') {
        if ($guestOSProfile) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                Remove-SCGuestOSProfile -GuestOSProfile $guestOSProfile -Force -ErrorAction Stop
                $guestOSProfile = $null
            }
        }
    }

    if ($guestOSProfile -and $state -eq 'present') {
        $module.Result.guest_os_profile = Get-SCVMMGuestOSProfileInfo -Profile $guestOSProfile
    }
}
catch {
    $global:Error.Clear()
    $module.FailJson("Failed to manage guest OS profile: $($_.Exception.Message)", $_)
}

$module.ExitJson()
