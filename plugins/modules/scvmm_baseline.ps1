#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_compliance

$spec = @{
    options = @{
        state = @{ type = 'str'; default = 'present'; choices = @('absent', 'present') }
        name = @{ type = 'str'; required = $true }
        description = @{ type = 'str' }
        updates = @{ type = 'list'; elements = 'str' }
        assignment_scope = @{ type = 'list'; elements = 'str' }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$state = $module.Params.state
$name = $module.Params.name
$description = $module.Params.description
$updates = $module.Params.updates
$assignment_scope = $module.Params.assignment_scope
$vmm_server = $module.Params.vmm_server

function Get-ScopeObject {
    param($IdOrName)
    $obj = Get-SCVMHostGroup -Name $IdOrName -ErrorAction SilentlyContinue
    if (-not $obj) { $obj = Get-SCVMHostCluster -Name $IdOrName -ErrorAction SilentlyContinue }
    if (-not $obj) { $obj = Get-SCManagedComputer -ComputerName $IdOrName -ErrorAction SilentlyContinue }
    return $obj
}

try {
    $getParams = @{ Name = $name; ErrorAction = "SilentlyContinue" }
    if ($vmm_server) { $getParams.VMMServer = $vmm_server }
    $current_baseline = Get-SCBaseline @getParams

    if ($state -eq 'present') {
        if (-not $current_baseline) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                $create_params = @{
                    Name = $name
                    ErrorAction = 'Stop'
                }
                if ($vmm_server) { $create_params.VMMServer = $vmm_server }
                if ($null -ne $description) { $create_params.Description = $description }

                $current_baseline = New-SCBaseline @create_params

                $update_params = @{}
                if ($updates) {
                    $update_objs = @()
                    foreach ($u in $updates) {
                        $update_objs += Get-SCUpdate -Name $u -ErrorAction Stop
                    }
                    $update_params.AddUpdates = $update_objs
                }

                if ($assignment_scope) {
                    $scope_objs = @()
                    foreach ($s in $assignment_scope) {
                        $obj = Get-ScopeObject -IdOrName $s
                        if (-not $obj) { $module.FailJson("Scope object '$s' not found.") }
                        $scope_objs += $obj
                    }
                    $update_params.AddAssignmentScope = $scope_objs
                }

                if ($update_params.Count -gt 0) {
                    Set-SCBaseline -Baseline $current_baseline @update_params -ErrorAction Stop
                }
            }
        }
        else {
            $changed = $false
            $update_params = @{}

            if ($null -ne $description -and $current_baseline.Description -ne $description) {
                $update_params.Description = $description
                $changed = $true
            }

            if ($null -ne $updates) {
                $current_update_ids = @($current_baseline.Updates | Select-Object -ExpandProperty ID)
                $target_update_objs = @()
                foreach ($u in $updates) {
                    $uo = Get-SCUpdate -Name $u -ErrorAction Stop
                    $target_update_objs += $uo
                }
                $target_update_ids = @($target_update_objs | Select-Object -ExpandProperty ID)

                $to_add = @()
                foreach ($uo in $target_update_objs) {
                    if ($uo.ID -notin $current_update_ids) { $to_add += $uo; $changed = $true }
                }

                $to_remove = @()
                foreach ($cu in $current_baseline.Updates) {
                    if ($cu.ID -notin $target_update_ids) { $to_remove += $cu; $changed = $true }
                }

                if ($to_add.Count -gt 0) { $update_params.AddUpdates = $to_add }
                if ($to_remove.Count -gt 0) { $update_params.RemoveUpdates = $to_remove }
            }

            if ($null -ne $assignment_scope) {
                $current_scope_ids = @($current_baseline.AssignmentScope | Select-Object -ExpandProperty ID)
                $target_scope_objs = @()
                foreach ($s in $assignment_scope) {
                    $so = Get-ScopeObject -IdOrName $s
                    if (-not $so) { $module.FailJson("Scope object '$s' not found.") }
                    $target_scope_objs += $so
                }
                $target_scope_ids = @($target_scope_objs | Select-Object -ExpandProperty ID)

                $to_add = @()
                foreach ($so in $target_scope_objs) {
                    if ($so.ID -notin $current_scope_ids) { $to_add += $so; $changed = $true }
                }

                $to_remove = @()
                foreach ($cs in $current_baseline.AssignmentScope) {
                    if ($cs.ID -notin $target_scope_ids) { $to_remove += $cs; $changed = $true }
                }

                if ($to_add.Count -gt 0) { $update_params.AddAssignmentScope = $to_add }
                if ($to_remove.Count -gt 0) { $update_params.RemoveAssignmentScope = $to_remove }
            }

            if ($changed) {
                $module.Result.changed = $true
                if (-not $module.CheckMode) {
                    Set-SCBaseline -Baseline $current_baseline @update_params -ErrorAction Stop
                }
            }
        }
        if ($current_baseline) {
            $module.Result.baseline = Get-SCVMMBaselineInfo -Baseline $current_baseline
        }
    }
    elseif ($state -eq 'absent') {
        if ($current_baseline) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                Remove-SCBaseline -Baseline $current_baseline -Confirm:$false -ErrorAction Stop
            }
        }
    }
}
catch {
    $module.FailJson("Error managing SCVMM baseline: $($_.Exception.Message)", $_)
}

$module.ExitJson()
