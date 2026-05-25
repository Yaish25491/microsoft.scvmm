# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

function Get-SCVMMCustomPropertyInfo {
    <#
    .SYNOPSIS
    Converts a SCVMM Custom Property object to a hashtable.
    .DESCRIPTION
    Extracts relevant properties from a CustomProperty object and returns a standardized hashtable.
    .PARAMETER CustomProperty
    The CustomProperty object to convert.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [Object]$CustomProperty
    )

    $info = @{
        name = $CustomProperty.Name
        id = $CustomProperty.ID.Guid
        description = $CustomProperty.Description
        members = $CustomProperty.Members
    }

    return $info
}

Export-ModuleMember -Function 'Get-SCVMMCustomPropertyInfo'
