# SCVMM Modules Sanity Fixes and Decennial Audit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix sanity test failures (PSAvoidAssignmentToAutomaticVariable, PSPlaceCloseBrace, trailing whitespace) and ensure consistent use of `Import-SCVMMModule` and object conversion utilities across 7 SCVMM modules.

**Architecture:** Surgical edits to PowerShell modules to comply with Ansible sanity standards and collection-wide utility patterns.

**Tech Stack:** PowerShell, Ansible

---

### Task 1: Fix scvmm_uplink_port_profile.ps1

**Files:**
- Modify: `plugins/modules/scvmm_uplink_port_profile.ps1`

- [ ] **Step 1: Rename $Profile to $UplinkProfile**
    - Find all occurrences of `$Profile` (which is an automatic variable in PowerShell) and rename them to `$UplinkProfile`.
    - Ensure function parameters and calls are updated.
- [ ] **Step 2: Fix PSPlaceCloseBrace**
    - Ensure `}` is on its own line before `else`, `catch`, or at the end of a block.
- [ ] **Step 3: Remove trailing whitespace**
    - Clean up all lines in the file.

### Task 2: Fix scvmm_host_network_adapter.ps1

**Files:**
- Modify: `plugins/modules/scvmm_host_network_adapter.ps1`

- [ ] **Step 1: Fix PSPlaceCloseBrace**
- [ ] **Step 2: Remove trailing whitespace**

### Task 3: Fix scvmm_mac_address_pool.ps1

**Files:**
- Modify: `plugins/modules/scvmm_mac_address_pool.ps1`

- [ ] **Step 1: Fix PSPlaceCloseBrace**
- [ ] **Step 2: Remove trailing whitespace**

### Task 4: Fix Info Modules (4 files)

**Files:**
- Modify: `plugins/modules/scvmm_host_network_adapter_info.ps1`
- Modify: `plugins/modules/scvmm_uplink_port_profile_info.ps1`
- Modify: `plugins/modules/scvmm_port_classification_info.ps1`
- Modify: `plugins/modules/scvmm_mac_address_pool_info.ps1`

- [ ] **Step 1: Fix PSPlaceCloseBrace in all 4 files**
- [ ] **Step 2: Remove trailing whitespace in all 4 files**
- [ ] **Step 3: Ensure Import-SCVMMModule is used consistently**

### Task 5: Verification

- [ ] **Step 1: Run sanity tests**
    - Run `ansible-test sanity --docker default plugins/modules/scvmm_host_network_adapter.ps1 plugins/modules/scvmm_host_network_adapter_info.ps1 plugins/modules/scvmm_uplink_port_profile.ps1 plugins/modules/scvmm_uplink_port_profile_info.ps1 plugins/modules/scvmm_port_classification_info.ps1 plugins/modules/scvmm_mac_address_pool.ps1 plugins/modules/scvmm_mac_address_pool_info.ps1`
