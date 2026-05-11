#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module Ansible.ModuleUtils.SCVMM

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

    $profiles = Get-SCApplicationProfile @params -ErrorAction Stop

    $profileList = @()
    if ($profiles) {
        foreach ($appProfile in $profiles) {
            $profileList += Get-SCVMMApplicationProfileInfo -ApplicationProfile $appProfile
        }
    }

    $module.Result.application_profiles = $profileList
}
catch {
    $global:Error.Clear()
    $module.FailJson("Failed to gather application profile info: $($_.Exception.Message)")
}

$module.ExitJson()
