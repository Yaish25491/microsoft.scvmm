#!powershell
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_library

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

$module.Result.templates = @()

try {
    $cmdletArgs = @{
        ErrorAction = "Stop"
    }

    if ($name) {
        $cmdletArgs.Name = $name
    }
    if ($vmm_server) {
        $cmdletArgs.VMMServer = $vmm_server
    }

    $templates = Get-SCVMTemplate @cmdletArgs

    if ($templates) {
        $templatesArray = @($templates)
        foreach ($template in $templatesArray) {
            $module.Result.templates += Get-SCVMMTemplateInfo -Template $template
        }
    }
}
catch {
    $module.FailJson("Failed to gather VM template info: $($_.Exception.Message)", $_)
}

$module.ExitJson()
