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
        path = @{ type = "str" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$path = $module.Params.path

try {
    # Import SCVMM module using utility
    Import-SCVMMModule -Module $module

    $cmdParams = @{
        ErrorAction = "Stop"
    }

    if ($name) {
        $cmdParams.Name = $name
    }

    $hostGroups = Get-SCVMHostGroup @cmdParams

    if ($path) {
        $hostGroups = $hostGroups | Where-Object { $_.Path -eq $path }
    }

    $results = @()
    if ($hostGroups) {
        # Normalize to array if single object returned
        if (-not ($hostGroups -is [array])) {
            $hostGroups = @($hostGroups)
        }
        foreach ($hg in $hostGroups) {
            $parent = $null
            if ($hg.ParentHostGroup) {
                $parent = $hg.ParentHostGroup.Name
            }

            $results += @{
                name = $hg.Name
                id = $hg.ID.ToString()
                path = $hg.Path
                description = $hg.Description
                parent_host_group = $parent
            }
        }
    }

    $module.Result.host_groups = $results
}
catch {
    $module.FailJson("Failed to gather SCVMM host group information: $($_.Exception.Message)", $_)
}

$module.ExitJson()
