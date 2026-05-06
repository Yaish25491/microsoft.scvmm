#!powershell
# Copyright: (c) 2024, Ansible Project
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module VirtualMachineManager
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

    $clouds = Get-SCCloud @cmdParams

    $results = @()
    if ($clouds) {
        # Normalize to array if single object returned
        if (-not ($clouds -is [array])) {
            $clouds = @($clouds)
        }
        foreach ($cloud in $clouds) {
            $results += Get-SCVMMCloudInfo -Cloud $cloud
        }
    }

    $module.Result.clouds = $results
}
catch {
    $module.FailJson("Failed to gather SCVMM private cloud information: $($_.Exception.Message)", $_)
}

$module.ExitJson()
