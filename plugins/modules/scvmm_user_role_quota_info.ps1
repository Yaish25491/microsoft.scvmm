#!powershell
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy
#Requires -Module microsoft.scvmm.plugins.module_utils.scvmm

#AnsibleRequires -CSharpUtil Ansible.Basic

$ErrorActionPreference = "Stop"

$spec = @{
    options = @{
        cloud = @{ type = "str" }
        user_role = @{ type = "str" }
        quota_per_user = @{ type = "bool" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$cloudName = $module.Params.cloud
$userRoleName = $module.Params.user_role
$quotaPerUser = $module.Params.quota_per_user

try {
    # Import SCVMM module using utility
    Import-SCVMMModule -Module $module

    $cmdParams = @{
        ErrorAction = "Stop"
    }

    if ($cloudName) {
        $cloudObj = Get-SCCloud -Name $cloudName -ErrorAction SilentlyContinue
        if (-not $cloudObj) {
            $module.FailJson("Cloud '$cloudName' was not found.")
        }
        $cmdParams.Cloud = $cloudObj
    }

    if ($userRoleName) {
        $userRoleObj = Get-SCUserRole -Name $userRoleName -ErrorAction SilentlyContinue
        if (-not $userRoleObj) {
            $module.FailJson("User Role '$userRoleName' was not found.")
        }
        $cmdParams.UserRole = $userRoleObj
    }

    if ($null -ne $quotaPerUser) {
        $cmdParams.QuotaPerUser = $quotaPerUser
    }

    $quotas = Get-SCUserRoleQuota @cmdParams

    $results = @()
    if ($quotas) {
        # Normalize to array if single object returned
        if (-not ($quotas -is [array])) {
            $quotas = @($quotas)
        }
        foreach ($quota in $quotas) {
            $results += Get-SCVMMUserRoleQuotaInfo -Quota $quota
        }
    }

    $module.Result.quotas = $results
}
catch {
    $global:Error.Clear()
    $module.FailJson("Failed to gather SCVMM user role quota information: $($_.Exception.Message)", $_)
}

$module.ExitJson()
