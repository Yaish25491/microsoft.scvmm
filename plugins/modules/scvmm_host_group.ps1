#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm_infra

#AnsibleRequires -CSharpUtil Ansible.Basic

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = "str"; required = $true }
        parent_group = @{ type = "str" }
        description = @{ type = "str" }
        state = @{ type = "str"; choices = "present", "absent"; default = "present" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$parent_group = $module.Params.parent_group
$description = $module.Params.description
$state = $module.Params.state

function Get-HostGroupInfo {
    param([Object]$hg)
    $parent = $null
    if ($hg.ParentHostGroup) {
        $parent = $hg.ParentHostGroup.Name
    }

    return @{
        name = $hg.Name
        id = $hg.ID.ToString()
        path = $hg.Path
        description = $hg.Description
        parent_host_group = $parent
    }
}

try {
    # Import SCVMM module using utility
    Import-SCVMMModule -Module $module

    # Check if the host group exists
    $existing_hg = $null
    try {
        $existing_hg = Get-SCVMHostGroup -Name $name -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $name }
        if ($existing_hg -is [array]) {
            # If multiple found, we might need parent_group to disambiguate.
            if ($parent_group) {
                $existing_hg = $existing_hg | Where-Object {
                    $_.ParentHostGroup.Name -eq $parent_group -or $_.ParentHostGroup.Path -eq $parent_group
                } | Select-Object -First 1
            }
            else {
                $existing_hg = $existing_hg[0]
            }
        }
    }
    catch {
        $existing_hg = $null
    }

    if ($state -eq "present") {
        if ($existing_hg) {
            # Check for changes
            $changes = @{}
            if ($null -ne $description -and $existing_hg.Description -ne $description) {
                $changes.Description = $description
            }

            if ($changes.Count -gt 0) {
                $module.Result.changed = $true
                if (-not $module.CheckMode) {
                    $existing_hg | Set-SCVMHostGroup @changes | Out-Null
                    # Re-fetch to get updated object
                    $existing_hg = Get-SCVMHostGroup -ID $existing_hg.ID
                }
            }
            $module.Result.host_group = Get-HostGroupInfo -hg $existing_hg
        }
        else {
            # Create new
            $module.Result.changed = $true
            $cmdParams = @{
                Name = $name
                ErrorAction = "Stop"
            }
            if ($description) {
                $cmdParams.Description = $description
            }

            if ($parent_group) {
                $parent_obj = Get-SCVMHostGroup -Name $parent_group -ErrorAction SilentlyContinue |
                    Where-Object { $_.Name -eq $parent_group -or $_.Path -eq $parent_group } |
                    Select-Object -First 1
                if (-not $parent_obj) {
                    $module.FailJson("Parent host group '$parent_group' not found.")
                }
                $cmdParams.VMHostGroup = $parent_obj
            }

            if (-not $module.CheckMode) {
                $new_hg = New-SCVMHostGroup @cmdParams
                $module.Result.host_group = Get-HostGroupInfo -hg $new_hg
            }
            else {
                # Predictive result for check mode
                $module.Result.host_group = @{
                    name = $name
                    description = $description
                    parent_host_group = $parent_group
                }
            }
        }
    }
    else {
        # state -eq "absent"
        if ($existing_hg) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                Remove-SCVMHostGroup -VMHostGroup $existing_hg -Confirm:$false
            }
        }
    }
}
catch {
    $module.FailJson("Failed to manage SCVMM host group: $($_.Exception.Message)", $_)
}

$module.ExitJson()
