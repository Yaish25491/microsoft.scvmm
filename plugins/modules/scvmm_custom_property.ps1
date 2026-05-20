#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_infra

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        add_member = @{ type = 'list'; elements = 'str' }
        remove_member = @{ type = 'list'; elements = 'str' }
        description = @{ type = 'str' }
        state = @{ type = 'str'; default = 'present'; choices = @('absent', 'present') }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$add_member = $module.Params.add_member
$remove_member = $module.Params.remove_member
$description = $module.Params.description
$state = $module.Params.state
$vmm_server = $module.Params.vmm_server

try {
    $params = @{ Name = $name; ErrorAction = "SilentlyContinue" }
    if ($vmm_server) { $params.VMMServer = $vmm_server }

    $property = Get-SCCustomProperty @params

    if ($state -eq 'present') {
        if (-not $property) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                $createParams = @{ Name = $name; ErrorAction = "Stop" }
                if ($description) { $createParams.Description = $description }
                if ($vmm_server) { $createParams.VMMServer = $vmm_server }
                if ($add_member) { $createParams.AddMember = $add_member }

                $property = New-SCCustomProperty @createParams
            }
        }
        else {
            $updateParams = @{ CustomProperty = $property; ErrorAction = "Stop" }
            $changed = $false

            if ($null -ne $description -and $property.Description -ne $description) {
                $updateParams.Description = $description
                $changed = $true
            }

            if ($null -ne $add_member) {
                $updateParams.AddMember = $add_member
                $changed = $true
            }

            if ($null -ne $remove_member) {
                $updateParams.RemoveMember = $remove_member
                $changed = $true
            }

            if ($changed) {
                $module.Result.changed = $true
                if (-not $module.CheckMode) {
                    $property = Set-SCCustomProperty @updateParams
                }
            }
        }
    }
    elseif ($state -eq 'absent') {
        if ($property) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                Remove-SCCustomProperty -CustomProperty $property -ErrorAction Stop
                $property = $null
            }
        }
    }

    if ($property) {
        $module.Result.custom_property = Get-SCVMMCustomPropertyInfo -CustomProperty $property
    }
}
catch {
    $module.FailJson("Failed to manage custom property: $($_.Exception.Message)", $_)
}

$module.ExitJson()
