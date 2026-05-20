#!powershell

# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic
#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_library

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
    $global:Error.Clear()

    if ($null -ne $name) {
        $profiles = @(Get-SCSQLProfile -Name $name -ErrorAction Ignore)
    }
    else {
        $profiles = @(Get-SCSQLProfile -ErrorAction Ignore)
    }

    $sql_profiles = @()
    if ($null -ne $profiles) {
        foreach ($profile in $profiles) {
            $sql_profiles += Get-SCVMMSQLProfileInfo -SQLProfile $profile
        }
    }

    $module.Result.sql_profiles = $sql_profiles
    $module.ExitJson()
}
catch {
    $module.FailJson("Failed to get SCVMM SQL Profile information: $($_.Exception.Message)", $_)
}
