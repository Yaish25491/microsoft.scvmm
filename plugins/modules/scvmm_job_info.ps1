#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_infra

#AnsibleRequires -CSharpUtil Ansible.Basic

$ErrorActionPreference = "Stop"

function Get-SCVMMJobInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Job object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a Job object and returns a standardized hashtable.
    .PARAMETER Job
    The Task object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Job
    )

    $info = @{
        name = $Job.Name
        id = $Job.ID.Guid
        status = if ($Job.Status) { $Job.Status.ToString() } else { $null }
        description = $Job.Description
        owner = $Job.Owner
        start_time = $Job.StartTime
        end_time = $Job.EndTime
        is_cancellable = $Job.IsCancellable
        is_restartable = $Job.IsRestartable
        result_object_name = $Job.ResultObjectName
        result_object_id = if ($Job.ResultObjectID) { $Job.ResultObjectID.Guid } else { $null }
        progress = $Job.Progress
        error_code = $Job.ErrorCode
        error_summary = $Job.ErrorSummary
    }

    return $info
}

$spec = @{
    options = @{
        id = @{ type = "str" }
        name = @{ type = "str" }
        status = @{ type = "str" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$id = $module.Params.id
$name = $module.Params.name
$status = $module.Params.status

$module.Result.jobs = @()

try {
    # Import SCVMM module using utility
    Import-SCVMMModule -Module $module

    $cmdletArgs = @{
        ErrorAction = "Stop"
    }

    if ($id) {
        $cmdletArgs.ID = $id
    }

    if ($name) {
        $cmdletArgs.Name = $name
    }

    # Get-SCJob has many parameters. If we want to filter by status, it's usually done via where-object or specific flags if available.
    # Checking Get-SCJob parameters. It doesn't have a -Status parameter directly in some versions,
    # but we can filter after getting the jobs.

    $jobs = Get-SCJob @cmdletArgs

    if ($jobs) {
        $jobsArray = @($jobs)

        if ($status) {
            $jobsArray = $jobsArray | Where-Object { $_.Status -eq $status -or $_.Status.ToString() -eq $status }
        }

        foreach ($job in $jobsArray) {
            $module.Result.jobs += Get-SCVMMJobInfo -Job $job
        }
    }
}
catch {
    $module.FailJson("Failed to gather job info: $($_.Exception.Message)", $_)
}

$module.ExitJson()
