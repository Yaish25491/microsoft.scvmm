#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_storage

$spec = @{
    options = @{
        name = @{ type = "str" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name

try {
    if ($null -ne $name) {
        $pools = Get-SCStoragePool -Name $name -ErrorAction SilentlyContinue
    }
    else {
        $pools = Get-SCStoragePool -All
    }

    $result = @{
        changed = $false
        storage_pools = $pools | ForEach-Object { Get-SCVMMStoragePoolInfo -StoragePool $_ }
    }

    $module.ExitJson($result)
}
catch {
    $module.FailJson("Failed to get storage pool information: $($_.Exception.Message)", $_)
}
