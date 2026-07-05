<#
.SYNOPSIS
Connects to an SCVMM server session.
#>
function Connect-SCVMMServerSession {
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Module,
        [string]$VMMServer
    )

    if (-not (Get-Module -Name VirtualMachineManager -ListAvailable)) {
        $Module.FailJson("The VirtualMachineManager PowerShell module is not installed.")
    }
    try {
        Import-Module -Name VirtualMachineManager -ErrorAction Stop
    }
    catch {
        $Module.FailJson("Failed to import VirtualMachineManager module: $($_.Exception.Message)")
    }

    $serverName = if ($VMMServer) {
        $VMMServer
    }
    else {
        "localhost"
    }
    try {
        $connection = Get-SCVMMServer -ComputerName $serverName -ErrorAction Stop
        return $connection
    }
    catch {
        $Module.FailJson("Failed to connect to SCVMM server '$serverName': $($_.Exception.Message)")
    }
}

<#
.SYNOPSIS
Removes a virtual machine from SCVMM by name.
#>
function Remove-SCVMMVirtualMachine {
    param(
        [Parameter(Mandatory = $true)]
        [Object]$Module,
        [Parameter(Mandatory = $true)]
        [Object]$VMMConnection,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $vm = Get-SCVirtualMachine -VMMServer $VMMConnection -Name $Name -ErrorAction Stop

    if ($vm -and $vm.Count -gt 1) {
        $Module.FailJson("Multiple VMs found with name '$Name'. Cannot determine which VM to remove.")
    }

    if (-not $vm) {
        return @{ changed = $false; vm = $null }
    }

    if (-not $Module.CheckMode) {
        if ($vm.Status -eq 'Running') {
            Stop-SCVirtualMachine -VM $vm -Force -ErrorAction Stop | Out-Null
        }
        Remove-SCVirtualMachine -VM $vm -Force -ErrorAction Stop | Out-Null
    }

    return @{ changed = $true; vm = $vm }
}

Export-ModuleMember -Function 'Connect-SCVMMServerSession', 'Remove-SCVMMVirtualMachine'
