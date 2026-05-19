#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm_network

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

    $portClassifications = Get-SCPortClassification @cmdParams

    $results = @()
    if ($portClassifications) {
        # Normalize to array if single object returned
        if (-not ($portClassifications -is [array])) {
            $portClassifications = @($portClassifications)
        }
        foreach ($pc in $portClassifications) {
            $results += Get-SCVMMPortClassificationInfo -PortClassification $pc
        }
    }

    $module.Result.port_classifications = $results
}
catch {
    $module.FailJson("Failed to gather SCVMM port classification information: $($_.Exception.Message)", $_)
}

$module.ExitJson()
