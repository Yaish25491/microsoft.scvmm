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
        vm = @{ type = "str" }
        vm_template = @{ type = "str" }
        vm_host = @{ type = "str" }
        vm_host_group = @{ type = "str" }
        cpu_count = @{ type = "int" }
        memory_mb = @{ type = "int" }
        disk_space_gb = @{ type = "int" }
        placement_goal = @{ type = "str"; choices = @("LoadBalance", "ResourceMaximization") }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

try {
    # Import SCVMM module using utility
    Import-SCVMMModule -Module $module

    $ratingParams = @{
        ErrorAction = "Stop"
    }

    # Input validation and parameter assignment
    if ($module.Params.vm) {
        $vm = Get-SCVirtualMachine -Name $module.Params.vm -ErrorAction Stop
        $ratingParams.VM = $vm
    }
    elseif ($module.Params.vm_template) {
        $template = Get-SCVMTemplate -Name $module.Params.vm_template -ErrorAction Stop
        $ratingParams.VMTemplate = $template
    }
    elseif ($null -ne $module.Params.cpu_count -or $null -ne $module.Params.memory_mb -or $null -ne $module.Params.disk_space_gb) {
        if ($null -eq $module.Params.cpu_count -or $null -eq $module.Params.memory_mb -or $null -eq $module.Params.disk_space_gb) {
            $module.FailJson("If using custom hardware requirements, all of cpu_count, memory_mb, and disk_space_gb must be provided.")
        }
        $ratingParams.CPUCount = $module.Params.cpu_count
        $ratingParams.MemoryMB = $module.Params.memory_mb
        $ratingParams.DiskSpaceGB = $module.Params.disk_space_gb
    }
    else {
        $module.FailJson("One of vm, vm_template, or hardware requirements (cpu_count, memory_mb, disk_space_gb) must be specified.")
    }

    if ($module.Params.vm_host) {
        $hostObj = Get-SCVMHost -ComputerName $module.Params.vm_host -ErrorAction Stop
        $ratingParams.VMHost = $hostObj
    }
    elseif ($module.Params.vm_host_group) {
        $hg = Get-SCVMHostGroup -Name $module.Params.vm_host_group -ErrorAction Stop
        $ratingParams.VMHostGroup = $hg
    }

    if ($module.Params.placement_goal) {
        $ratingParams.PlacementGoal = $module.Params.placement_goal
    }

    $ratings = Get-SCVMHostRating @ratingParams

    $results = @()
    if ($ratings) {
        if (-not ($ratings -is [array])) {
            $ratings = @($ratings)
        }
        foreach ($rating in $ratings) {
            $results += @{
                vm_host = $rating.VMHost.Name
                rating = $rating.Rating
                explanation = $rating.Explanation
                is_eligible = $rating.IsEligible
            }
        }
    }

    $module.Result.host_ratings = $results
}
catch {
    $module.FailJson("Failed to gather SCVMM host rating information: $($_.Exception.Message)", $_)
}

$module.ExitJson()
