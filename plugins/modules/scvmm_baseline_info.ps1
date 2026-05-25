#!powershell
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_compliance

#AnsibleRequires -CSharpUtil Ansible.Basic

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

    $baselines = Get-SCBaseline @cmdParams

    $results = @()
    if ($baselines) {
        if (-not ($baselines -is [array])) {
            $baselines = @($baselines)
        }
        foreach ($baseline in $baselines) {
            $results += Get-SCVMMBaselineInfo -Baseline $baseline
        }
    }

    $module.Result.baselines = $results
}
catch {
    $module.FailJson("Failed to gather SCVMM baseline information: $($_.Exception.Message)", $_)
}

$module.ExitJson()
