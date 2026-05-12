#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        computer_name = @{ type = 'str' }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$computer_name = $module.Params.computer_name
$vmm_server = $module.Params.vmm_server

try {
    $params = @{ ErrorAction = "Stop" }
    if ($computer_name) {
        $params.ComputerName = $computer_name
    }
    if ($vmm_server) {
        $params.VMMServer = $vmm_server
    }

    $servers = Get-SCLibraryServer @params

    $results = @()
    if ($servers) {
        $serversArray = @($servers)
        foreach ($srv in $serversArray) {
            $results += Get-SCVMMLibraryServerInfo -LibraryServer $srv
        }
    }

    $module.Result.library_servers = $results
}
catch {
    $module.FailJson("Failed to gather library server info: $($_.Exception.Message)", $_)
}

$module.ExitJson()
