#!powershell
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_network

$params = @{
    name = @{ type = 'str'; required = $true }
    logical_network = @{ type = 'str' }
    description = @{ type = 'str' }
    isolation_type = @{ type = 'str'; choices = @('NoIsolation', 'Isolated') }
    state = @{ type = 'str'; choices = @('absent', 'present'); default = 'present' }
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $params)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$logical_network_name = $module.Params.logical_network
$description = $module.Params.description
$isolation_type = $module.Params.isolation_type
$state = $module.Params.state

$vm_network = Get-SCVMNetwork -Name $name -ErrorAction SilentlyContinue

if ($state -eq 'present') {
    if ($null -eq $vm_network) {
        if ($null -eq $logical_network_name) {
            $module.FailJson("logical_network is required when creating a new VM Network.")
        }

        $logical_network = Get-SCLogicalNetwork -Name $logical_network_name -ErrorAction SilentlyContinue
        if ($null -eq $logical_network) {
            $module.FailJson("Logical network '$logical_network_name' not found.")
        }

        $module.Result.changed = $true
        if ($module.CheckMode) {
            $module.ExitJson()
        }

        try {
            $create_params = @{
                Name = $name
                LogicalNetwork = $logical_network
                ErrorAction = 'Stop'
            }
            if ($null -ne $description) { $create_params.Description = $description }
            if ($null -ne $isolation_type) { $create_params.IsolationType = $isolation_type }

            $vm_network = New-SCVMNetwork @create_params
        }
        catch {
            $module.FailJson("Failed to create VM Network '$name': $($_.Exception.Message)", $_)
        }
    }
    else {
        # Update existing
        $update_params = @{}

        if ($null -ne $description -and $vm_network.Description -ne $description) {
            $update_params.Description = $description
        }

        # Note: LogicalNetwork and IsolationType are typically immutable after creation for some network types,
        # but check if we need to support updating them if SCVMM allows.
        # For this implementation, we focus on Description as a common updateable property.

        if ($update_params.Count -gt 0) {
            $module.Result.changed = $true
            if ($module.CheckMode) {
                # Return info as if it were updated
                $info = Get-SCVMMVMNetworkInfo -VMNetwork $vm_network
                foreach ($key in $update_params.Keys) {
                    $info[$key.ToLower()] = $update_params[$key]
                }
                $module.Result.vm_network = $info
                $module.ExitJson()
            }

            try {
                $vm_network = Set-SCVMNetwork -VMNetwork $vm_network @update_params -ErrorAction Stop
            }
            catch {
                $module.FailJson("Failed to update VM Network '$name': $($_.Exception.Message)", $_)
            }
        }
    }

    $module.Result.vm_network = Get-SCVMMVMNetworkInfo -VMNetwork $vm_network
}
elseif ($state -eq 'absent') {
    if ($null -ne $vm_network) {
        $module.Result.changed = $true
        if ($module.CheckMode) {
            $module.ExitJson()
        }

        try {
            Remove-SCVMNetwork -VMNetwork $vm_network -ErrorAction Stop
        }
        catch {
            $module.FailJson("Failed to remove VM Network '$name': $($_.Exception.Message)", $_)
        }
    }
}

$module.ExitJson()
