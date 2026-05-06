#!powershell
# Copyright: (c) 2024, Ansible Project
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module VirtualMachineManager
#AnsibleRequires -CSharpUtil Ansible.Basic

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        name = @{ type = "str" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name

$module.Result.templates = @()

try {
    $cmdletArgs = @{
        ErrorAction = "Stop"
    }

    if ($name) {
        $cmdletArgs.Name = $name
    }

    $templates = Get-SCVMTemplate @cmdletArgs

    if ($templates) {
        $templatesArray = @($templates)
        foreach ($template in $templatesArray) {
            $module.Result.templates += @{
                name = $template.Name
                id = $template.ID.Guid
                description = $template.Description
                owner = $template.Owner
                cpu_count = $template.CPUCount
                memory = $template.Memory
                dynamic_memory_enabled = $template.DynamicMemoryEnabled
                operating_system = if ($template.OperatingSystem) { $template.OperatingSystem.Name } else { $null }
                is_highly_available = $template.IsHighlyAvailable
                library_server = if ($template.LibraryServer) { $template.LibraryServer.Name } else { $null }
            }
        }
    }
}
catch {
    $module.FailJson("Failed to gather VM template info: $($_.Exception.Message)", $_)
}

$module.ExitJson()
