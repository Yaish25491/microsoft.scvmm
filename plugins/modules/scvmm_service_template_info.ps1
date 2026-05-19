#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

$spec = @{
    options = @{
        name = @{ type = 'str' }
        release = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$release = $module.Params.release

Import-SCVMMModule -Module $module

$getParams = @{}
if ($name) {
    $getParams.Name = $name
}
if ($release) {
    $getParams.Release = $release
}

try {
    $templates = @(Get-SCServiceTemplate @getParams -ErrorAction Stop)
}
catch {
    $global:Error.Clear()
    $module.FailJson("Failed to get service templates: $($_.Exception.Message)")
}

$result = @()
foreach ($template in $templates) {
    $result += Get-SCVMMServiceTemplateInfo -ServiceTemplate $template
}

$module.Result.service_templates = $result
$module.ExitJson()
