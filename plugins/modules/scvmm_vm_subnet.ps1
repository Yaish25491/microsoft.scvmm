#!powershell
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm
#AnsibleRequires -PowerShell ansible_collections.microsoft.scvmm.plugins.module_utils.scvmm_network

function Compare-SubnetVLan {
    param(
        [Parameter(Mandatory = $true)]
        [Object[]]$Current,
        [Parameter(Mandatory = $true)]
        [Object[]]$Desired
    )

    if ($Current.Count -ne $Desired.Count) {
        return $false
    }

    $sortedCurrent = $Current | Sort-Object Subnet, VLanID
    $sortedDesired = $Desired | Sort-Object subnet, vlan

    for ($i = 0; $i -lt $sortedCurrent.Count; $i++) {
        if ($sortedCurrent[$i].Subnet -ne $sortedDesired[$i].subnet) { return $false }
        if ($sortedCurrent[$i].VLanID -ne $sortedDesired[$i].vlan) { return $false }
    }

    return $true
}

$params = @{
    name = @{ type = 'str'; required = $true }
    vm_network = @{ type = 'str' }
    description = @{ type = 'str' }
    subnet_vlans = @{ type = 'list'; elements = 'dict' }
    max_number_of_ports = @{ type = 'int' }
    port_acl = @{ type = 'str' }
    state = @{ type = 'str'; choices = @('absent', 'present'); default = 'present' }
}

$module = [Ansible.ModuleUtils.Legacy.AnsibleModule]::Create($args, $params)

Import-SCVMMModule -Module $module

$name = $module.Params.name
$vm_network_name = $module.Params.vm_network
$description = $module.Params.description
$subnet_vlans_raw = $module.Params.subnet_vlans
$max_number_of_ports = $module.Params.max_number_of_ports
$port_acl_name = $module.Params.port_acl
$state = $module.Params.state

$vm_subnet = Get-SCVMSubnet -Name $name -ErrorAction SilentlyContinue

if ($state -eq 'present') {
    if ($null -eq $vm_subnet) {
        if ($null -eq $vm_network_name) {
            $module.FailJson("vm_network is required when creating a new VM Subnet.")
        }
        if ($null -eq $subnet_vlans_raw -or $subnet_vlans_raw.Count -eq 0) {
            $module.FailJson("subnet_vlans is required when creating a new VM Subnet.")
        }

        $vm_network = Get-SCVMNetwork -Name $vm_network_name -ErrorAction SilentlyContinue
        if ($null -eq $vm_network) {
            $module.FailJson("VM Network '$vm_network_name' not found.")
        }

        $subnet_vlans = @()
        foreach ($sv in $subnet_vlans_raw) {
            $sv_params = @{ Subnet = $sv.subnet }
            if ($null -ne $sv.vlan) { $sv_params.VLanID = $sv.vlan }
            $subnet_vlans += New-SCSubnetVLan @sv_params
        }

        $module.Result.changed = $true
        if ($module.CheckMode) {
            $module.ExitJson()
        }

        try {
            $create_params = @{
                Name = $name
                VMNetwork = $vm_network
                SubnetVLan = $subnet_vlans
                ErrorAction = 'Stop'
            }
            if ($null -ne $description) { $create_params.Description = $description }
            if ($null -ne $port_acl_name) {
                $port_acl = Get-SCPortACL -Name $port_acl_name -ErrorAction SilentlyContinue
                if ($null -eq $port_acl) { $module.FailJson("Port ACL '$port_acl_name' not found.") }
                $create_params.PortACL = $port_acl
            }

            $vm_subnet = New-SCVMSubnet @create_params

            # MaxNumberOfPorts might need a separate Set call if not supported in New-SCVMSubnet
            if ($null -ne $max_number_of_ports) {
                $vm_subnet = Set-SCVMSubnet -VMSubnet $vm_subnet -MaxNumberOfPorts $max_number_of_ports -ErrorAction Stop
            }
        }
        catch {
            $module.FailJson("Failed to create VM Subnet '$name': $($_.Exception.Message)", $_)
        }
    }
    else {
        # Update existing
        $update_params = @{}

        if ($null -ne $description -and $vm_subnet.Description -ne $description) {
            $update_params.Description = $description
        }

        if ($null -ne $max_number_of_ports -and $vm_subnet.MaxNumberOfPorts -ne $max_number_of_ports) {
            $update_params.MaxNumberOfPorts = $max_number_of_ports
        }

        if ($null -ne $port_acl_name) {
            if ($null -eq $vm_subnet.PortACL -or $vm_subnet.PortACL.Name -ne $port_acl_name) {
                $port_acl = Get-SCPortACL -Name $port_acl_name -ErrorAction SilentlyContinue
                if ($null -eq $port_acl) { $module.FailJson("Port ACL '$port_acl_name' not found.") }
                $update_params.PortACL = $port_acl
            }
        }

        if ($null -ne $subnet_vlans_raw) {
            if (-not (Compare-SubnetVLan -Current $vm_subnet.SubnetVLans -Desired $subnet_vlans_raw)) {
                $subnet_vlans = @()
                foreach ($sv in $subnet_vlans_raw) {
                    $sv_params = @{ Subnet = $sv.subnet }
                    if ($null -ne $sv.vlan) { $sv_params.VLanID = $sv.vlan }
                    $subnet_vlans += New-SCSubnetVLan @sv_params
                }
                $update_params.SubnetVLan = $subnet_vlans
            }
        }

        if ($update_params.Count -gt 0) {
            $module.Result.changed = $true
            if ($module.CheckMode) {
                $info = Get-SCVMMVMSubnetInfo -VMSubnet $vm_subnet
                foreach ($key in $update_params.Keys) {
                    $lowKey = $key.ToLower()
                    if ($lowKey -eq 'portacl') { $info['port_acl'] = $port_acl_name } elseif ($lowKey -eq 'subnetvlan') {
                        $info['subnet_vlans'] = $subnet_vlans_raw
                    }
                    else {
                        $info[$lowKey] = $update_params[$key]
                    }
                }
                $module.Result.vm_subnet = $info
                $module.ExitJson()
            }

            try {
                $vm_subnet = Set-SCVMSubnet -VMSubnet $vm_subnet @update_params -ErrorAction Stop
            }
            catch {
                $module.FailJson("Failed to update VM Subnet '$name': $($_.Exception.Message)", $_)
            }
        }
    }

    $module.Result.vm_subnet = Get-SCVMMVMSubnetInfo -VMSubnet $vm_subnet
}
elseif ($state -eq 'absent') {
    if ($null -ne $vm_subnet) {
        $module.Result.changed = $true
        if ($module.CheckMode) {
            $module.ExitJson()
        }

        try {
            Remove-SCVMSubnet -VMSubnet $vm_subnet -ErrorAction Stop
        }
        catch {
            $module.FailJson("Failed to remove VM Subnet '$name': $($_.Exception.Message)", $_)
        }
    }
}

$module.ExitJson()
