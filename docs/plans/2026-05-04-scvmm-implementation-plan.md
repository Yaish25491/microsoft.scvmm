# SCVMM Collection Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Red Hat certified Ansible Collection (`microsoft.scvmm`) to manage Microsoft SCVMM hybrid infrastructure via WinRM, spanning 97 modules across 15 epics.

**Architecture:** Split architecture (Python stubs for documentation/specs + PowerShell for execution). Utilizes a shared `SCVMM.psm1` module utility to map Ansible variables to SCVMM cmdlets securely, mirroring the proven design of the `microsoft.hyperv` collection.

**Tech Stack:** Ansible Core >= 2.15.0, `ansible.windows` >= 2.0.0, PowerShell, WinRM.

---

## Architecture Decisions & Consolidation Strategy
With 97 proposed modules covering extreme granularity (e.g., `scvmm_vm_scsi_adapter`, `scvmm_vm_dvd_drive`), we have a critical architectural decision to make. While Jira lists 97 individual endpoints, we must determine if building 97 discrete Ansible modules provides the best UX, or if we should consolidate related endpoints into unified declarative modules (e.g., managing `scvmm_vm` with `disks:` and `nics:` parameters vs separate `scvmm_vm_disk` and `scvmm_vm_nic` modules). 

For Phase 1, we will stick to the 1-to-1 mapping specified in the Jira tasks for the foundational utilities and core `Info` discovery modules, but we will port the `module_utils` from Hyper-V immediately to prevent rewriting WinRM parsing logic 97 times.

---

## Phase 1: Foundation & Utilities

Porting utilities from `microsoft.hyperv` to `microsoft.scvmm` is the highest priority. It guarantees proven idempotency mechanisms across all 97 modules.

### Task 1: Create SCVMM.psm1 Utilities

**Files:**
- Create: `plugins/module_utils/SCVMM.psm1`

- [ ] **Step 1: Write the connection and mapping implementation**
```powershell
# plugins/module_utils/SCVMM.psm1
Function Get-SCVMMServerConnection {
    param([Hashtable]$ModuleArgs)
    # Stub for connecting to SCVMM Server via Get-SCVMMServer
    return $true
}

Function Get-SCVMMParametersFromMap {
    param([Hashtable]$Map, [Hashtable]$Spec)
    $Result = @{}
    foreach ($Key in $Map.Keys) {
        if ($Spec.ContainsKey($Key) -and $null -ne $Spec[$Key]) {
            $Result[$Map[$Key]] = $Spec[$Key]
        }
    }
    return $Result
}

Function Test-SCVMMPropertiesChanged {
    param([Hashtable]$Desired, [psobject]$Current)
    $Changed = $false
    foreach ($Key in $Desired.Keys) {
        if ($Current.$Key -ne $Desired[$Key]) {
            $Changed = $true
            break
        }
    }
    return $Changed
}

Export-ModuleMember -Function Get-SCVMMServerConnection, Get-SCVMMParametersFromMap, Test-SCVMMPropertiesChanged
```

- [ ] **Step 2: Commit utilities**
```bash
git add plugins/module_utils/SCVMM.psm1
git commit -m "feat: add core SCVMM powershell utilities ported from hyperv"
```

---

## Phase 2: Core Discovery (Info Modules)
Because there are dozens of `_info` modules (e.g., `scvmm_vm_info`, `scvmm_host_info`, `scvmm_cloud_info`), establishing a rock-solid pattern for one will unlock parallel development for the rest.

### Task 2: Implement `scvmm_vm_info` (Epic ACA-5512)

**Files:**
- Create: `plugins/modules/scvmm_vm_info.py`
- Create: `plugins/modules/scvmm_vm_info.ps1`
- Test: `tests/integration/targets/scvmm_vm_info/tasks/main.yml`

- [ ] **Step 1: Write the failing integration test**
```yaml
# tests/integration/targets/scvmm_vm_info/tasks/main.yml
- name: Gather info on SCVMM VMs
  microsoft.scvmm.scvmm_vm_info:
    name: "TestVM"
  register: vm_info

- name: Verify info returned
  assert:
    that:
      - vm_info.vms is defined
```

- [ ] **Step 2: Write Python stub documentation**
```python
# plugins/modules/scvmm_vm_info.py
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_vm_info
short_description: Gather information about SCVMM VMs
description:
  - Retrieve details about virtual machines managed by SCVMM.
options:
  name:
    description: Name of the VM to query.
    type: str
author:
  - Red Hat
'''

EXAMPLES = r'''
- name: Get VM info
  microsoft.scvmm.scvmm_vm_info:
    name: "Web01"
'''

RETURN = r'''
vms:
  description: List of VMs.
  returned: always
  type: list
'''
```

- [ ] **Step 3: Write PowerShell implementation**
```powershell
# plugins/modules/scvmm_vm_info.ps1
#AnsibleRequires -PowerShell microsoft.scvmm.SCVMM

$spec = @{
    options = @{
        name = @{ type = "str" }
    }
    supports_check_mode = $true
}
$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)
$module.Result.vms = @()
$module.ExitJson()
```

- [ ] **Step 4: Commit info module**
```bash
git add plugins/modules/scvmm_vm_info.* tests/integration/targets/scvmm_vm_info/
git commit -m "feat: implement scvmm_vm_info baseline"
```

---

## Phase 3: High-Priority Management Epics
Once the utilities and info patterns are proven, we will scale out horizontally. Due to the volume (97 modules), we will group execution by Epic.

### Task 3: VM Lifecycle Management (Epic ACA-5512)
- Implement `scvmm_vm`
- Implement `scvmm_vm_state`
- Implement `scvmm_vm_migrate`
- Implement `scvmm_vm_clone`

### Task 4: Template & Cloud Management (Epics ACA-5513 & ACA-5514)
- Implement `scvmm_template`
- Implement `scvmm_cloud`
- Implement `scvmm_host`
- Implement `scvmm_host_group`

### Task 5: Networking & Storage (Epics ACA-5515 & ACA-5516)
- Implement `scvmm_logical_network`
- Implement `scvmm_vm_network`
- Implement `scvmm_logical_switch`
- Implement `scvmm_virtual_hard_disk`
- Implement `scvmm_storage_pool`

*(The remaining 70+ modules across Profiles, Bare Metal, Update/Compliance, RBAC, and Peripherals will be implemented following the exact same template pattern once Phases 1-3 are verified.)*

---

## Phase 4: CI/CD Pipeline Verification

### Task 6: Validate CI Pipelines against New Seed Modules
**Files:**
- Modify: `.azure-pipelines/azure-pipelines.yml` (if needed)

- [ ] **Step 1: Emulate CI locally**
```bash
ansible-test sanity
```
- [ ] **Step 2: Trigger CI**
```bash
git push origin HEAD
```