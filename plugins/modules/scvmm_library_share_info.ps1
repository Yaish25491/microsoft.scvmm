#!powershell
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy

$ErrorActionPreference = 'Stop'

$spec = @{
    options = @{
        name = @{ type = 'str' }
        library_server = @{ type = 'str' }
        vmm_server = @{ type = 'str' }
        vmm_username = @{ type = 'str' }
        vmm_password = @{ type = 'str'; no_log = $true }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$library_server = $module.Params.library_server

Import-SCVMMModule -Module $module

try {
    $vmmParams = @{}
    if ($module.Params.vmm_server) {
        $vmmParams.VMMServer = $module.Params.vmm_server
    }

    $results = Get-SCLibraryShare @vmmParams -ErrorAction Stop

    $shares = New-Object System.Collections.ArrayList
    if ($results) {
        if ($results -isnot [array]) {
            $results = @($results)
        }
        foreach ($res in $results) {
            $match = $true
            if ($name -and $res.Name -ne $name) {
                $match = $false
            }
            if ($library_server -and $res.LibraryServer.Name -ne $library_server) {
                $match = $false
            }

            if ($match) {
                $null = $shares.Add((Get-SCVMMLibraryShareInfo -LibraryShare $res))
            }
        }
    }

    $module.Result.library_shares = $shares
    $module.ExitJson()
}
catch {
    $global:Error.Clear()
    $err = $_.Exception.Message
    $module.FailJson("Failed to gather library share information: $err")
}
