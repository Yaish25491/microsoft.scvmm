#!powershell
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_rbac

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = 'str' }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$vmm_server = $module.Params.vmm_server

try {
    $params = @{ ErrorAction = "Stop" }
    if ($name) { $params.Name = $name }
    if ($vmm_server) { $params.VMMServer = $vmm_server }

    $roles = Get-SCUserRole @params

    $results = @()
    if ($roles) {
        $rolesArray = @($roles)
        foreach ($role in $rolesArray) {
            $results += Get-SCVMMUserRoleInfo -UserRole $role
        }
    }

    $module.Result.user_roles = $results
}
catch {
    $module.FailJson("Failed to gather user role info: $($_.Exception.Message)", $_)
}

$module.ExitJson()
