# SCVMM Module Refactoring Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor 10 PowerShell modules in the `microsoft.scvmm` collection to use a newly created shared utility module `plugins/module_utils/scvmm.psm1`.

**Architecture:** Replace redundant `VirtualMachineManager` module import logic and object-to-dictionary conversion logic with standardized functions from `scvmm.psm1`.

**Tech Stack:** PowerShell (Ansible Windows)

---

### Task 1: Refactor scvmm_vm_state.ps1

**Files:**
- Modify: `plugins/modules/scvmm_vm_state.ps1`

- [ ] **Step 1: Add module utility requirement**
- [ ] **Step 2: Replace manual module import with Import-SCVMMModule**
- [ ] **Step 3: Replace VM status extraction if applicable (it uses status directly for logic, check if Get-SCVMMVMInfo helps)**

### Task 2: Refactor scvmm_vm_info.ps1

**Files:**
- Modify: `plugins/modules/scvmm_vm_info.ps1`

- [ ] **Step 1: Add module utility requirement**
- [ ] **Step 2: Replace manual module import logic**
- [ ] **Step 3: Replace dictionary creation loop with Get-SCVMMVMInfo**

### Task 3: Refactor scvmm_host_group_info.ps1

**Files:**
- Modify: `plugins/modules/scvmm_host_group_info.ps1`

- [ ] **Step 1: Add module utility requirement**
- [ ] **Step 2: Replace manual module import logic**

### Task 4: Refactor scvmm_cloud.ps1

**Files:**
- Modify: `plugins/modules/scvmm_cloud.ps1`

- [ ] **Step 1: Add module utility requirement**
- [ ] **Step 2: Replace manual module import logic**

### Task 5: Refactor scvmm_cloud_info.ps1

**Files:**
- Modify: `plugins/modules/scvmm_cloud_info.ps1`

- [ ] **Step 1: Add module utility requirement**
- [ ] **Step 2: Replace manual module import logic**
- [ ] **Step 3: Replace dictionary creation loop with Get-SCVMMCloudInfo**

### Task 6: Refactor scvmm_vm_checkpoint.ps1

**Files:**
- Modify: `plugins/modules/scvmm_vm_checkpoint.ps1`

- [ ] **Step 1: Add module utility requirement**
- [ ] **Step 2: Replace manual module import logic**

### Task 7: Refactor scvmm_vm_migrate.ps1

**Files:**
- Modify: `plugins/modules/scvmm_vm_migrate.ps1`

- [ ] **Step 1: Add module utility requirement**
- [ ] **Step 2: Replace manual module import logic**

### Task 8: Refactor scvmm_vm_clone.ps1

**Files:**
- Modify: `plugins/modules/scvmm_vm_clone.ps1`

- [ ] **Step 1: Add module utility requirement**
- [ ] **Step 2: Replace manual module import logic**

### Task 9: Refactor scvmm_template.ps1

**Files:**
- Modify: `plugins/modules/scvmm_template.ps1`

- [ ] **Step 1: Add module utility requirement**
- [ ] **Step 2: Replace manual module import logic**

### Task 10: Refactor scvmm_template_info.ps1

**Files:**
- Modify: `plugins/modules/scvmm_template_info.ps1`

- [ ] **Step 1: Add module utility requirement**
- [ ] **Step 2: Replace manual module import logic**
- [ ] **Step 3: Replace dictionary creation loop with Get-SCVMMTemplateInfo**
