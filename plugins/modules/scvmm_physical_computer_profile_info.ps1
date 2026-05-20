#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_compliance

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

$module.Result.physical_computer_profiles = @()

try {
    $cmdletArgs = @{
        ErrorAction = "Stop"
    }

    if ($name) {
        $cmdletArgs.Name = $name
    }

    $profiles = Get-SCPhysicalComputerProfile @cmdletArgs

    if ($profiles) {
        $profilesArray = @($profiles)
        foreach ($profile in $profilesArray) {
            $module.Result.physical_computer_profiles += Get-SCPhysicalComputerProfileInfo -Profile $profile
        }
    }
}
catch {
    $module.FailJson("Failed to gather physical computer profile info: $($_.Exception.Message)", $_)
}

$module.ExitJson()
