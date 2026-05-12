#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module Ansible.ModuleUtils.scvmm

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
    } else {
        $result = Get-SCService -ErrorAction Stop
    }

    if ($result) {
        if ($result -is [array]) {
            foreach ($service in $result) {
                $services += Get-SCVMMServiceInfo -Service $service
            }
        } else {
            $services += Get-SCVMMServiceInfo -Service $result
        }
    }
} catch {
    $global:Error.Clear()
    $module.FailJson("Failed to get SCVMM services: $($_.Exception.Message)")
}

$module.Result.services = $services
$module.ExitJson()