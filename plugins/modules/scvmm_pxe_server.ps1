#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm_compliance

$params = Parse-Args $args -operators $true
$check_mode = Get-AnsibleParam -obj $params -name "_ansible_check_mode" -type "bool" -default $false

$spec = @{
    computer_name = @{ type = "str"; required = $true }
    credential = @{ type = "dict" }
    description = @{ type = "str" }
    state = @{ type = "str"; choices = "absent", "present"; default = "present" }
    force = @{ type = "bool"; default = $false }
}

$module = [Ansible.Basic.AnsibleModule]::Create($params, $spec)

Import-SCVMMModule -Module $module

$computer_name = $module.Params.computer_name
$credential_dict = $module.Params.credential
$description = $module.Params.description
$state = $module.Params.state
$force = $module.Params.force

$pxe_server = Get-SCPXEServer -ComputerName $computer_name -ErrorAction SilentlyContinue

if ($state -eq "present") {
    if ($null -eq $pxe_server) {
        if ($null -eq $credential_dict -or [string]::IsNullOrEmpty($credential_dict.name)) {
            $module.FailJson("A credential with a Run As Account name is required when adding a PXE server.")
        }

        $run_as_account = Get-SCRunAsAccount -Name $credential_dict.name -ErrorAction SilentlyContinue
        if ($null -eq $run_as_account) {
            $module.FailJson("The Run As Account '$($credential_dict.name)' was not found.")
        }

        $module.Result.changed = $true
        if (-not $check_mode) {
            $add_params = @{
                ComputerName = $computer_name
                Credential = $run_as_account
            }
            if ($null -ne $description) {
                $add_params.Description = $description
            }

            try {
                $pxe_server = Add-SCPXEServer @add_params -ErrorAction Stop
            }
            catch {
                $module.FailJson("Failed to add PXE server: $($_.Exception.Message)")
            }
        }
    }
    else {
        # Check if updates are needed (Description)
        if ($null -ne $description -and $pxe_server.Description -ne $description) {
            $module.Result.changed = $true
            if (-not $check_mode) {
                try {
                    $pxe_server = Set-SCPXEServer -PXEServer $pxe_server -Description $description -ErrorAction Stop
                }
                catch {
                    $module.FailJson("Failed to update PXE server description: $($_.Exception.Message)")
                }
            }
        }
    }

    if ($null -ne $pxe_server) {
        $module.Result.pxe_server = Get-SCPXEServerInfo -PXEServer $pxe_server
    }
}
elseif ($state -eq "absent") {
    if ($null -ne $pxe_server) {
        $module.Result.changed = $true
        $module.Result.pxe_server = Get-SCPXEServerInfo -PXEServer $pxe_server

        if (-not $check_mode) {
            $remove_params = @{
                PXEServer = $pxe_server
            }
            if ($force) {
                $remove_params.Force = $true
            }
            else {
                if ($null -eq $credential_dict -or [string]::IsNullOrEmpty($credential_dict.name)) {
                    $msg = "A credential with a Run As Account name is required to uninstall the VMM agent from the PXE server, unless 'force' is true."
                    $module.FailJson($msg)
                }

                $run_as_account = Get-SCRunAsAccount -Name $credential_dict.name -ErrorAction SilentlyContinue
                if ($null -eq $run_as_account) {
                    $module.FailJson("The Run As Account '$($credential_dict.name)' was not found.")
                }
                # Remove-SCPXEServer expects PSCredential for -Credential if not using Run As Account?
                # Actually Add-SCPXEServer takes VMMCredential which Get-SCRunAsAccount returns.
                # Let's check Remove-SCPXEServer.
                $remove_params.Credential = $run_as_account
            }

            try {
                Remove-SCPXEServer @remove_params -ErrorAction Stop
            }
            catch {
                $module.FailJson("Failed to remove PXE server: $($_.Exception.Message)")
            }
        }
    }
}

$module.ExitJson()
