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

try {
    $cmdParams = @{
        ErrorAction = "Stop"
    }

    if ($name) {
        $cmdParams.Name = $name
    }

    $clouds = Get-SCCloud @cmdParams

    $results = @()
    if ($clouds) {
        # Normalize to array if single object returned
        if (-not ($clouds -is [array])) {
            $clouds = @($clouds)
        }
        foreach ($cloud in $clouds) {
            $hostGroups = @()
            if ($cloud.VMHostGroups) {
                foreach ($hg in $cloud.VMHostGroups) {
                    $hostGroups += $hg.Path
                }
            }

            $readOnlyShares = @()
            if ($cloud.ReadOnlyLibraryShares) {
                foreach ($share in $cloud.ReadOnlyLibraryShares) {
                    $readOnlyShares += $share.Name
                }
            }

            $capabilityProfiles = @()
            if ($cloud.CapabilityProfiles) {
                foreach ($profile in $cloud.CapabilityProfiles) {
                    $capabilityProfiles += $profile.Name
                }
            }

            $results += @{
                name = $cloud.Name
                id = $cloud.ID.ToString()
                description = $cloud.Description
                host_groups = $hostGroups
                read_only_library_shares = $readOnlyShares
                read_write_library_path = $cloud.ReadWriteLibraryPath
                capability_profiles = $capabilityProfiles
            }
        }
    }

    $module.Result.clouds = $results
}
catch {
    $module.FailJson("Failed to gather SCVMM private cloud information: $($_.Exception.Message)", $_)
}

$module.ExitJson()
