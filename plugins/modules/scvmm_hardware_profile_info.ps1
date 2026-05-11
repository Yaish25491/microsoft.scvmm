#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module Ansible.ModuleUtils.CommandUtil

$ErrorActionPreference = 'Stop'

$spec = @{
    options = @{
        name = @{ type = 'str' }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$vmm_server = $module.Params.vmm_server

$module_utils_path = Join-Path -Path $module.ModuleDir -ChildPath '..\module_utils\scvmm.psm1'
Import-Module -Name $module_utils_path -ErrorAction Stop

Import-SCVMMModule -Module $module

$params = @{}
if ($vmm_server) {
    $params['VMMServer'] = $vmm_server
}

try {
    if ($name) {
        $hw_profiles = Get-SCHardwareProfile -Name $name @params -ErrorAction Ignore
    }
    else {
        $hw_profiles = Get-SCHardwareProfile @params -ErrorAction Ignore
    }

    $hw_profiles_list = @()
    if ($hw_profiles) {
        foreach ($hw_profile in $hw_profiles) {
            $hw_profiles_list += Get-SCVMMHardwareProfileInfo -HardwareProfile $hw_profile
        }
    }

    $module.Result.hardware_profiles = $hw_profiles_list
}
catch {
    $global:Error.Clear()
    $module.FailJson("Failed to gather hardware profile information: $($_.Exception.Message)")
}

$global:Error.Clear()
$module.ExitJson()