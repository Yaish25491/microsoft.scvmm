#!powershell
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module Ansible.ModuleUtils.CommandUtil

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = "str"; required = $true }
        description = @{ type = "str" }
        state = @{ type = "str"; choices = @("present", "absent"); default = "present" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$description = $module.Params.description
$state = $module.Params.state

Import-SCVMMModule -Module $module

$changed = $false

try {
    $existingClassification = Get-SCPortClassification -Name $name -ErrorAction Ignore | Select-Object -First 1

    if ($state -eq "present") {
        if (-not $existingClassification) {
            $changed = $true
            if (-not $module.CheckMode) {
                $params = @{
                    Name = $name
                }
                if ($null -ne $description) {
                    $params.Description = $description
                }
                $existingClassification = New-SCPortClassification @params -ErrorAction Stop
            }
        }
        else {
            if ($null -ne $description -and $existingClassification.Description -cne $description) {
                $changed = $true
                if (-not $module.CheckMode) {
                    $setParams = @{
                        PortClassification = $existingClassification
                        Description = $description
                    }
                    $existingClassification = Set-SCPortClassification @setParams -ErrorAction Stop
                }
            }
        }
    }
    elseif ($state -eq "absent") {
        if ($existingClassification) {
            $changed = $true
            if (-not $module.CheckMode) {
                Remove-SCPortClassification -PortClassification $existingClassification -ErrorAction Stop
            }
        }
    }
}
catch {
    $global:Error.Clear()
    $module.FailJson("Failed to manage port classification: $($_.Exception.Message)")
}

if ($state -eq "present" -and $existingClassification) {
    if ($module.CheckMode) {
        # Fabricate the returned object based on desired state to keep idempotency checks happy
        $info = @{
            name = $name
            id = if ($existingClassification.ID) { $existingClassification.ID.Guid } else { [Guid]::Empty.ToString() }
            description = if ($null -ne $description) { $description } else { $existingClassification.Description }
        }
    }
    else {
        $info = Get-SCVMMPortClassificationInfo -PortClassification $existingClassification
    }
    $module.Result.port_classification = $info
}

$module.Result.changed = $changed
$global:Error.Clear()
$module.ExitJson()
