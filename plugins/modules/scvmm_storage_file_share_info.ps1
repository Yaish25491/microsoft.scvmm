#!powershell
# Copyright: (c) 2026, Gemini (@gemini)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

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
        $shares = Get-SCStorageFileShare -Name $name -ErrorAction SilentlyContinue
    }
    else {
        $shares = Get-SCStorageFileShare -ErrorAction Stop
    }

    $shareInfo = @()
    foreach ($share in $shares) {
        $shareInfo += Get-SCVMMStorageFileShareInfo -StorageFileShare $share
    }

    $module.Result.storage_file_shares = $shareInfo
}
catch {
    $module.FailJson("Failed to gather storage file share information: $($_.Exception.Message)")
}

$module.ExitJson()
