#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_infra

#AnsibleRequires -CSharpUtil Ansible.Basic

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        state = @{ type = 'str'; default = 'present'; choices = @('absent', 'present') }
        name = @{ type = 'str'; required = $true }
        description = @{ type = 'str' }
        start_date = @{ type = 'str' }
        start_time_of_day = @{ type = 'str' }
        duration = @{ type = 'int' }
        duration_unit = @{ type = 'str'; choices = @('Hours', 'Minutes'); default = 'Hours' }
        time_zone = @{ type = 'int' }
        weekly_recurrence = @{
            type = 'list'
            elements = 'str'
            choices = @('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday')
        }
        monthly_recurrence = @{ type = 'int' }
        occurrence = @{ type = 'int' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$state = $module.Params.state
$name = $module.Params.name
$description = $module.Params.description
$start_date = $module.Params.start_date
$start_time_of_day = $module.Params.start_time_of_day
$duration = $module.Params.duration
$duration_unit = $module.Params.duration_unit
$time_zone = $module.Params.time_zone
$weekly_recurrence = $module.Params.weekly_recurrence
$monthly_recurrence = $module.Params.monthly_recurrence
$occurrence = $module.Params.occurrence

try {
    # Import SCVMM module using utility
    Import-SCVMMModule -Module $module

    $current_window = Get-SCServicingWindow -Name $name -ErrorAction SilentlyContinue

    if ($state -eq 'present') {
        if (-not $current_window) {
            # Create
            $new_params = @{
                Name = $name
                ErrorAction = "Stop"
            }

            if ($null -ne $description) { $new_params.Description = $description }
            if ($null -ne $start_date) { $new_params.StartDate = [DateTime]$start_date }
            if ($null -ne $start_time_of_day) { $new_params.StartTimeOfDay = [DateTime]$start_time_of_day }
            if ($null -ne $duration) { $new_params.Duration = $duration }
            if ($null -ne $duration_unit) { $new_params.DurationUnit = $duration_unit }
            if ($null -ne $time_zone) { $new_params.TimeZone = $time_zone }
            if ($null -ne $weekly_recurrence) { $new_params.WeeklyRecurrence = $weekly_recurrence }
            if ($null -ne $monthly_recurrence) { $new_params.MonthlyRecurrence = $monthly_recurrence }
            if ($null -ne $occurrence) { $new_params.Occurrence = $occurrence }

            if ($module.CheckMode) {
                $module.Result.changed = $true
                $module.ExitJson()
            }

            New-SCServicingWindow @new_params
            $module.Result.changed = $true
        }
        else {
            # Update
            $changed = $false
            $update_params = @{
                ServicingWindow = $current_window
                ErrorAction = "Stop"
            }

            if ($null -ne $description -and $current_window.Description -ne $description) {
                $update_params.Description = $description
                $changed = $true
            }

            if ($null -ne $start_date) {
                $dt_start_date = [DateTime]$start_date
                if ($current_window.StartDate.Date -ne $dt_start_date.Date) {
                    $update_params.StartDate = $dt_start_date
                    $changed = $true
                }
            }

            if ($null -ne $start_time_of_day) {
                $dt_start_time = [DateTime]$start_time_of_day
                if ($current_window.StartTimeOfDay.TimeOfDay -ne $dt_start_time.TimeOfDay) {
                    $update_params.StartTimeOfDay = $dt_start_time
                    $changed = $true
                }
            }

            if ($null -ne $duration -and $current_window.Duration -ne $duration) {
                $update_params.Duration = $duration
                $changed = $true
            }

            # DurationUnit is usually not settable via Set-SCServicingWindow in some versions,
            # but let's check if it needs changing. Duration in object is in minutes or hours?
            # Usually Duration is returned in Minutes in some objects.

            if ($null -ne $time_zone -and $current_window.TimeZone -ne $time_zone) {
                $update_params.TimeZone = $time_zone
                $changed = $true
            }

            if ($null -ne $weekly_recurrence) {
                $current_weekly = @($current_window.WeeklyRecurrence | ForEach-Object { $_.ToString() })
                $diff = Compare-Object $current_weekly $weekly_recurrence
                if ($null -ne $diff) {
                    $update_params.WeeklyRecurrence = $weekly_recurrence
                    $changed = $true
                }
            }

            # Monthly and Occurrence might also need checks if supported by Set-SCServicingWindow

            if ($changed) {
                if ($module.CheckMode) {
                    $module.Result.changed = $true
                    $module.ExitJson()
                }

                Set-SCServicingWindow @update_params
                $module.Result.changed = $true
            }
        }
    }
    elif ($state -eq 'absent') {
        if ($current_window) {
            if ($module.CheckMode) {
                $module.Result.changed = $true
                $module.ExitJson()
            }

            Remove-SCServicingWindow -ServicingWindow $current_window -Confirm:$false -ErrorAction Stop
            $module.Result.changed = $true
        }
    }
}
catch {
    $module.FailJson("Error managing SCVMM servicing window: $($_.Exception.Message)", $_)
}

$module.ExitJson()
