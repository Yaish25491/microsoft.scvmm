#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module VirtualMachineManager
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -CSharpUtil Ansible.Basic

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $true }
        state = @{ type = 'str'; default = 'present'; choices = @('absent', 'present') }
        description = @{ type = 'str' }
        mac_address_range_start = @{ type = 'str' }
        mac_address_range_end = @{ type = 'str' }
        host_groups = @{ type = 'list'; elements = 'str' }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name
$state = $module.Params.state
$description = $module.Params.description
$mac_address_range_start = $module.Params.mac_address_range_start
$mac_address_range_end = $module.Params.mac_address_range_end
$host_groups = $module.Params.host_groups

$module.Result.changed = $false

try {
    Import-SCVMMModule -Module $module

    $pool = Get-SCMACAddressPool -Name $name -ErrorAction SilentlyContinue

    if ($pool -is [array] -and $pool.Count -gt 1) {
        $module.FailJson("Multiple MAC address pools found with the name '$name'.")
    }

    if ($state -eq 'present') {
        if (-not $pool) {
            # Creation
            if ($null -eq $mac_address_range_start) { $module.FailJson("mac_address_range_start is required when creating a new MAC address pool.") }
            if ($null -eq $mac_address_range_end) { $module.FailJson("mac_address_range_end is required when creating a new MAC address pool.") }
            if ($null -eq $host_groups -or $host_groups.Count -eq 0) { $module.FailJson("host_groups is required when creating a new MAC address pool.") }

            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                $hgObjects = @()
                foreach ($hgName in $host_groups) {
                    $hg = Get-SCVMHostGroup -Name $hgName -ErrorAction SilentlyContinue
                    if (-not $hg) { $module.FailJson("Host group '$hgName' not found.") }
                    $hgObjects += $hg
                }

                $createParams = @{
                    Name = $name
                    MACAddressRangeStart = $mac_address_range_start
                    MACAddressRangeEnd = $mac_address_range_end
                    VMHostGroup = $hgObjects
                    ErrorAction = "Stop"
                }
                if ($description) { $createParams.Description = $description }

                $pool = New-SCMACAddressPool @createParams
            }
        }
        else {
            # Update
            $updateParams = @{ MACAddressPool = $pool; ErrorAction = "Stop" }
            $needsUpdate = $false

            if ($null -ne $description -and $pool.Description -ne $description) {
                $updateParams.Description = $description
                $needsUpdate = $true
            }

            if ($null -ne $host_groups) {
                $currentHgNames = $pool.VMHostGroups | ForEach-Object { $_.Name } | Sort-Object
                $desiredHgNames = $host_groups | Sort-Object

                # Check if arrays are different
                $diff = Compare-Object -ReferenceObject $currentHgNames -DifferenceObject $desiredHgNames
                if ($diff) {
                    $hgObjects = @()
                    foreach ($hgName in $host_groups) {
                        $hg = Get-SCVMHostGroup -Name $hgName -ErrorAction SilentlyContinue
                        if (-not $hg) { $module.FailJson("Host group '$hgName' not found.") }
                        $hgObjects += $hg
                    }
                    $updateParams.VMHostGroup = $hgObjects
                    $needsUpdate = $true
                }
            }

            if ($needsUpdate) {
                $module.Result.changed = $true
                if (-not $module.CheckMode) {
                    $pool = Set-SCMACAddressPool @updateParams
                }
            }
        }
    }
    elseif ($state -eq 'absent') {
        if ($pool) {
            $module.Result.changed = $true
            if (-not $module.CheckMode) {
                Remove-SCMACAddressPool -MACAddressPool $pool -ErrorAction Stop
            }
        }
    }

    if ($pool -and $state -eq 'present') {
        $module.Result.mac_address_pool = Get-SCVMMMACAddressPoolInfo -MACAddressPool $pool
    }
    elseif ($module.CheckMode -and -not $pool -and $state -eq 'present') {
        $module.Result.mac_address_pool = @{
            name = $name
            description = $description
            mac_address_range_start = $mac_address_range_start
            mac_address_range_end = $mac_address_range_end
            host_groups = $host_groups
        }
    }
}
catch {
    $module.FailJson("An error occurred: $($_.Exception.Message)", $_)
}

$module.ExitJson()
