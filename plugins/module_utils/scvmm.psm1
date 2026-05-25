# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy

function Import-SCVMMModule {
    <#
    .SYNOPSIS
    Imports the VirtualMachineManager module.
    .DESCRIPTION
    Checks if the VirtualMachineManager module is available and imports it. Fails the Ansible module if not found.
    .PARAMETER Module
    The Ansible module object used for failing the execution if the module is not found.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification = 'Standard Ansible utility naming')]
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Module
    )

    if (-not (Get-Module -Name VirtualMachineManager -ListAvailable)) {
        $Module.FailJson("The VirtualMachineManager PowerShell module is not installed or available.")
    }

    try {
        Import-Module -Name VirtualMachineManager -ErrorAction Stop
    }
    catch {
        $Module.FailJson("Failed to import VirtualMachineManager module: $($_.Exception.Message)")
    }
}

Export-ModuleMember -Function 'Import-SCVMMModule'
