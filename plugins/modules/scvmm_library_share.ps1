#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        share_path = @{ type = 'str' }
        description = @{ type = 'str' }
        library_server = @{ type = 'str' }
        state = @{ type = 'str'; default = 'present'; choices = @('absent', 'present') }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$share_path = $module.Params.share_path
$description = $module.Params.description
$library_server_name = $module.Params.library_server
$state = $module.Params.state
$vmm_server = $module.Params.vmm_server

try {
    $getParams = @{ Name = $name; ErrorAction = "SilentlyContinue" }
    if ($vmm_server) {
        $getParams.VMMServer = $vmm_server
    }

    $share = Get-SCLibraryShare @getParams

    if ($state -eq 'present') {
        if (-not $share) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                if (-not $share_path -or -not $library_server_name) {
                    $module.FailJson("share_path and library_server are required to add a new library share.")
                }

                $libServer = Get-SCLibraryServer -ComputerName $library_server_name -ErrorAction SilentlyContinue
                if (-not $libServer) {
                    $module.FailJson("Library Server '$library_server_name' not found.")
                }

                $createParams = @{
                    SharePath = $share_path
                    LibraryServer = $libServer
                    ErrorAction = "Stop"
                }
                if ($description) {
                    $createParams.Description = $description
                }

                $share = Add-SCLibraryShare @createParams
            }
        }
        else {
            $changed = $false
            $updateParams = @{ LibraryShare = $share; ErrorAction = "Stop" }

            if ($null -ne $description -and $share.Description -ne $description) {
                $updateParams.Description = $description
                $changed = $true
            }

            if ($changed) {
                $module.Result.changed = $true
                if (-not $module.CheckMode) {
                    $share = Set-SCLibraryShare @updateParams
                }
            }
        }
    }
    elseif ($state -eq 'absent') {
        if ($share) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                Remove-SCLibraryShare -LibraryShare $share -Force -ErrorAction Stop
                $share = $null
            }
        }
    }

    if ($share) {
        $module.Result.library_share = Get-SCVMMLibraryShareInfo -LibraryShare $share
    }
}
catch {
    $module.FailJson("Failed to manage Library Share: $($_.Exception.Message)", $_)
}

$module.ExitJson()
