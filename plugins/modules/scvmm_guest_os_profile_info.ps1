#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name

$module.Result.guest_os_profiles = @()

try {
    $cmdletArgs = @{
        ErrorAction = "Stop"
    }

    if ($name) {
        $cmdletArgs.Name = $name
    }

    $profiles = Get-SCGuestOSProfile @cmdletArgs

    if ($profiles) {
        $profilesArray = @($profiles)
        foreach ($profile in $profilesArray) {
            $module.Result.guest_os_profiles += Get-SCVMMGuestOSProfileInfo -Profile $profile
        }
    }
}
catch {
    $module.FailJson("Failed to gather guest OS profile info: $($_.Exception.Message)", $_)
}

$module.ExitJson()
