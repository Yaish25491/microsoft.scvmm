#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm_library

$ErrorActionPreference = 'Stop'

$spec = @{
    options = @{
        name = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name

try {
    $params = @{}
    if ($name) {
        $params.Name = $name
    }

    $profiles = Get-SCCapabilityProfile @params -ErrorAction SilentlyContinue

    $profileList = @()
    if ($profiles) {
        foreach ($capProfile in $profiles) {
            $profileList += Get-SCVMMCapabilityProfileInfo -CapabilityProfile $capProfile
        }
    }

    $module.Result.capability_profiles = $profileList
}
catch {
    $global:Error.Clear()
    $module.FailJson("Failed to gather capability profile info: $($_.Exception.Message)")
}

$module.ExitJson()
