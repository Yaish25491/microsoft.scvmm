#!powershell
# Copyright: (c) 2026, Steve Fulmer
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

$services = @()

try {
    if ($name) {
        $result = Get-SCService -Name $name -ErrorAction Stop
    }
    else {
        $result = Get-SCService -ErrorAction Stop
    }

    if ($result) {
        if ($result -is [array]) {
            foreach ($service in $result) {
                $services += Get-SCVMMServiceInfo -Service $service
            }
        }
        else {
            $services += Get-SCVMMServiceInfo -Service $result
        }
    }
}
catch {
    $global:Error.Clear()
    $module.FailJson("Failed to get SCVMM services: $($_.Exception.Message)")
}

$module.Result.services = $services
$module.ExitJson()
