#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

#AnsibleRequires -CSharpUtil Ansible.Basic

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = "str" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name

try {
    # Import SCVMM module using utility
    Import-SCVMMModule -Module $module

    $cmdParams = @{
        ErrorAction = "Stop"
    }

    if ($name) {
        $cmdParams.Name = $name
    }

    $profiles = Get-SCUplinkPortProfile @cmdParams

    $results = @()
    if ($profiles) {
        # Normalize to array if single object returned
        if (-not ($profiles -is [array])) {
            $profiles = @($profiles)
        }
        foreach ($profile in $profiles) {
            $results += Get-SCVMMUplinkPortProfileInfo -UplinkPortProfile $profile
        }
    }

    $module.Result.uplink_port_profiles = $results
}
catch {
    $module.FailJson("Failed to gather SCVMM uplink port profile information: $($_.Exception.Message)", $_)
}

$module.ExitJson()
