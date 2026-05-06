#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        computer_name = @{ type = 'str'; required = $true }
        port = @{ type = 'int'; default = 8530 }
        use_ssl = @{ type = 'bool'; default = $false }
        credential = @{ type = 'str' }
        state = @{ type = 'str'; default = 'present'; choices = @('absent', 'present') }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$computer_name = $module.Params.computer_name
$port = $module.Params.port
$use_ssl = $module.Params.use_ssl
$credential_name = $module.Params.credential
$state = $module.Params.state
$vmm_server = $module.Params.vmm_server

try {
    $getParams = @{ ComputerName = $computer_name; ErrorAction = "SilentlyContinue" }
    if ($vmm_server) { $getParams.VMMServer = $vmm_server }
    $server = Get-SCUpdateServer @getParams

    if ($state -eq 'present') {
        if (-not $server) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                $addParams = @{
                    ComputerName = $computer_name
                    TCPPort = $port
                    ErrorAction = "Stop"
                }
                if ($vmm_server) { $addParams.VMMServer = $vmm_server }
                if ($use_ssl) { $addParams.UsedSSL = $true }
                if ($credential_name) {
                    $raa = Get-SCRunAsAccount -Name $credential_name -ErrorAction Stop
                    $addParams.Credential = $raa
                }
                $server = Add-SCUpdateServer @addParams
            }
        }
        else {
            $changed = $false
            $updateParams = @{ UpdateServer = $server; ErrorAction = "Stop" }

            if ($server.Port -ne $port) { $updateParams.TCPPort = $port; $changed = $true }

            if ($changed) {
                $module.Result.changed = $true
                if (-not $module.CheckMode) {
                    $server = Set-SCUpdateServer @updateParams
                }
            }
        }
    }
    elseif ($state -eq 'absent') {
        if ($server) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                Remove-SCUpdateServer -UpdateServer $server -Force -ErrorAction Stop
                $server = $null
            }
        }
    }

    if ($server) {
        $module.Result.update_server = Get-SCUpdateServerInfo -UpdateServer $server
    }
}
catch {
    $module.FailJson("Failed to manage update server: $($_.Exception.Message)", $_)
}

$module.ExitJson()
