# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

function Get-SCVMMBaselineInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Baseline object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a Baseline object and returns a standardized hashtable.
    .PARAMETER Baseline
    The SCBaseline object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Baseline
    )

    $info = @{
        name = $Baseline.Name
        id = $Baseline.ID.Guid
        description = $Baseline.Description
        updates = $Baseline.Updates | ForEach-Object {
            @{
                name = $_.Name
                id = $_.ID.Guid
                bulletin_id = $_.BulletinID
            }
        }
        assignment_scope = $Baseline.AssignmentScope | ForEach-Object {
            @{
                name = $_.Name
                id = $_.ID.Guid
                type = $_.GetType().Name
            }
        }
    }

    return $info
}

function Get-SCVMMComplianceStatusInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Compliance Status object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a ComplianceStatus object and returns a standardized hashtable.
    .PARAMETER ComplianceStatus
    The ComplianceStatus object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$ComplianceStatus
    )

    $info = @{
        compliance_status = if ($ComplianceStatus.ComplianceStatus) { $ComplianceStatus.ComplianceStatus.ToString() } else { $null }
        last_scan_time = $ComplianceStatus.LastScanTime
        object_name = if ($ComplianceStatus.ItemName) { $ComplianceStatus.ItemName } elseif ($ComplianceStatus.Name) { $ComplianceStatus.Name } else { $null }
        object_type = if ($ComplianceStatus.ItemType) { $ComplianceStatus.ItemType.ToString() } else { $null }
        baseline_name = if ($ComplianceStatus.Baseline) { $ComplianceStatus.Baseline.Name } else { $null }
        error_code = $ComplianceStatus.ErrorCode
        error_description = $ComplianceStatus.ErrorDescription
    }

    return $info
}

Export-ModuleMember -Function 'Get-SCVMMBaselineInfo', 'Get-SCVMMComplianceStatusInfo'
