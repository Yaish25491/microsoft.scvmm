# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

function Get-SCVMMServiceInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Service object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a Service object and returns a standardized hashtable.
    .PARAMETER Service
    The SCService object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Service
    )

    $info = @{
        name = $Service.Name
        id = $Service.ID.Guid
        description = $Service.Description
        status = if ($Service.Status) { $Service.Status.ToString() } else { $null }
        service_template = if ($Service.ServiceTemplate) { $Service.ServiceTemplate.Name } else { $null }
        user_role = if ($Service.UserRole) { $Service.UserRole.Name } else { $null }
        owner = $Service.Owner
        release = $Service.Release
        cost_center = $Service.CostCenter
        is_recoverable = $Service.IsRecoverable
    }

    return $info
}

Export-ModuleMember -Function 'Get-SCVMMServiceInfo'
