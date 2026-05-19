#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm_rbac

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        username = @{ type = 'str' }
        password = @{ type = 'str'; no_log = $true }
        description = @{ type = 'str' }
        state = @{ type = 'str'; default = 'present'; choices = @('absent', 'present') }
        vmm_server = @{ type = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$username = $module.Params.username
$password = $module.Params.password
$description = $module.Params.description
$state = $module.Params.state
$vmm_server = $module.Params.vmm_server

try {
    $getParams = @{ Name = $name; ErrorAction = "SilentlyContinue" }
    if ($vmm_server) { $getParams.VMMServer = $vmm_server }

    $raa = Get-SCRunAsAccount @getParams

    if ($state -eq 'present') {
        if (-not $raa) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                if (-not $username -or -not $password) {
                    $module.FailJson("username and password are required to create a new Run As Account.")
                }

                $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
                $cred = New-Object System.Management.Automation.PSCredential ($username, $securePassword)

                $createParams = @{
                    Name = $name
                    Credential = $cred
                    ErrorAction = "Stop"
                }
                if ($description) { $createParams.Description = $description }
                if ($vmm_server) { $createParams.VMMServer = $vmm_server }

                $raa = New-SCRunAsAccount @createParams
            }
        }
        else {
            $changed = $false
            $updateParams = @{ RunAsAccount = $raa; ErrorAction = "Stop" }

            if ($null -ne $description -and $raa.Description -ne $description) {
                $updateParams.Description = $description
                $changed = $true
            }

            if ($null -ne $username -or $null -ne $password) {
                $u = if ($username) { $username } else { $raa.Username }
                $p = if ($password) { $password } else { "dummy" }

                if ($password -or ($username -and $raa.Username -ne $username)) {
                    $securePassword = ConvertTo-SecureString $p -AsPlainText -Force
                    $cred = New-Object System.Management.Automation.PSCredential ($u, $securePassword)
                    $updateParams.Credential = $cred
                    $changed = $true
                }
            }

            if ($changed) {
                $module.Result.changed = $true
                if (-not $module.CheckMode) {
                    $raa = Set-SCRunAsAccount @updateParams
                }
            }
        }
    }
    elseif ($state -eq 'absent') {
        if ($raa) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                Remove-SCRunAsAccount -RunAsAccount $raa -Force -ErrorAction Stop
                $raa = $null
            }
        }
    }

    if ($raa) {
        $module.Result.run_as_account = Get-SCVMMRunAsAccountInfo -RunAsAccount $raa
    }
}
catch {
    $module.FailJson("Failed to manage Run As Account: $($_.Exception.Message)", $_)
}

$module.ExitJson()
