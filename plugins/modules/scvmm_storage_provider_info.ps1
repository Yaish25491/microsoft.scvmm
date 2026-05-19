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
        $providers = Get-SCStorageProvider -Name $name -ErrorAction SilentlyContinue
    }
    else {
        $providers = Get-SCStorageProvider -ErrorAction Stop
    }

    $providerInfo = @()
    foreach ($provider in $providers) {
        $providerInfo += Get-SCVMMStorageProviderInfo -StorageProvider $provider
    }

    $module.Result.storage_providers = $providerInfo
}
catch {
    $module.FailJson("Failed to gather storage provider information: $($_.Exception.Message)")
}

$module.ExitJson()
