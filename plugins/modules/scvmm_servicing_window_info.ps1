#!powershell
# Copyright: (c) 2026, Ansible Project
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module VirtualMachineManager
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -CSharpUtil Ansible.Basic

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = "str" }
        id = @{ type = "str" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$id = $module.Params.id

try {
    # Import SCVMM module using utility
    Import-SCVMMModule -Module $module

    $cmdParams = @{
        ErrorAction = "Stop"
    }

    if ($id) {
        $cmdParams.ID = $id
    }
    elseif ($name) {
        $cmdParams.Name = $name
    }

    $windows = Get-SCServicingWindow @cmdParams

    $results = @()
    if ($windows) {
        if (-not ($windows -is [array])) {
            $windows = @($windows)
        }
        foreach ($window in $windows) {
            $windowInfo = @{
                name = $window.Name
                id = $window.ID.Guid
                description = $window.Description
                start_date = if ($window.StartDate) { $window.StartDate.ToString("yyyy-MM-ddTHH:mm:ss") } else { $null }
                start_time_of_day = if ($window.StartTimeOfDay) { $window.StartTimeOfDay.ToString("yyyy-MM-ddTHH:mm:ss") } else { $null }
                duration = $window.Duration
                duration_unit = if ($window.DurationUnit) { $window.DurationUnit.ToString() } else { $null }
                time_zone = $window.TimeZone
                expiry_date = if ($window.ExpiryDate) { $window.ExpiryDate.ToString("yyyy-MM-ddTHH:mm:ss") } else { $null }
            }
            $results += $windowInfo
        }
    }

    $module.Result.servicing_windows = $results
}
catch {
    $module.FailJson("Failed to gather SCVMM servicing window information: $($_.Exception.Message)", $_)
}

$module.ExitJson()
