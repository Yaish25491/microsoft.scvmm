#!powershell
#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

$spec = @{
    options = @{
        state = @{ type = 'str'; default = 'present'; choices = @('absent', 'present') }
        name = @{ type = 'str'; required = $true }
        host_group = @{ type = 'list'; elements = 'str' }
        description = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$state = $module.Params.state
$name = $module.Params.name
$host_group = $module.Params.host_group
$description = $module.Params.description

try {
    # Import SCVMM module using utility
    Import-SCVMMModule -Module $module

    # Fail fast if attempting to create without host_group
    if ($state -eq 'present' -and $null -eq $host_group) {
        # Check if the cloud already exists to know if we are creating
        $existing_cloud = Get-SCCloud -Name $name -ErrorAction SilentlyContinue
        if (-not $existing_cloud) {
            $module.FailJson("host_group is required when creating a new cloud.")
        }
    }

    $current_cloud = Get-SCCloud -Name $name -ErrorAction SilentlyContinue

    if ($state -eq 'present') {
        if (-not $current_cloud) {
            # Create
            $hg_objects = @()
            if ($host_group) {
                foreach ($hg_name in $host_group) {
                    $group = Get-SCVMHostGroup -Name $hg_name -ErrorAction Stop
                    $hg_objects += $group
                }
            }

            if ($module.CheckMode) {
                $module.Result.changed = $true
                $module.ExitJson()
            }

            $new_cloud = New-SCCloud -Name $name -VMHostGroup $hg_objects -Description $description -ErrorAction Stop
            $module.Result.changed = $true
        } else {
            # Update
            $changed = $false
            $update_params = @{}

            if ($null -ne $description -and $current_cloud.Description -ne $description) {
                $update_params.Description = $description
                $changed = $true
            }

            # Handle host group updates if host_group is provided
            if ($null -ne $host_group) {
                $current_hg_names = @($current_cloud.VMHostGroup | Select-Object -ExpandProperty Name)
                
                $hgs_to_add = @()
                foreach ($hg in $host_group) {
                    if ($hg -notin $current_hg_names) {
                        $group = Get-SCVMHostGroup -Name $hg -ErrorAction Stop
                        $hgs_to_add += $group
                        $changed = $true
                    }
                }
                
                $hgs_to_remove = @()
                foreach ($hg in $current_hg_names) {
                    if ($hg -notin $host_group) {
                        $group = Get-SCVMHostGroup -Name $hg -ErrorAction Stop
                        $hgs_to_remove += $group
                        $changed = $true
                    }
                }

                if ($hgs_to_add.Count -gt 0) {
                    $update_params.AddVMHostGroup = $hgs_to_add
                }
                if ($hgs_to_remove.Count -gt 0) {
                    $update_params.RemoveVMHostGroup = $hgs_to_remove
                }
            }

            if ($changed) {
                if ($module.CheckMode) {
                    $module.Result.changed = $true
                    $module.ExitJson()
                }

                Set-SCCloud -Cloud $current_cloud @update_params -ErrorAction Stop
                $module.Result.changed = $true
            }
        }
    } elseif ($state -eq 'absent') {
        if ($current_cloud) {
            # Delete
            if ($module.CheckMode) {
                $module.Result.changed = $true
                $module.ExitJson()
            }

            Remove-SCCloud -Cloud $current_cloud -Confirm:$false -ErrorAction Stop
            $module.Result.changed = $true
        }
    }
} catch {
    $module.FailJson("Error managing SCVMM cloud: $($_.Exception.Message)")
}

$module.ExitJson()
