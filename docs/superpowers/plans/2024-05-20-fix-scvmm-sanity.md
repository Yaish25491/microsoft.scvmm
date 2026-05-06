# Fix SCVMM Collection Sanity Failures Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix sanity test failures in `microsoft.scvmm` collection modules to ensure they pass `ansible-test sanity`.

**Architecture:** Surgical fixes to YAML documentation, PowerShell script structure, and argument synchronization.

**Tech Stack:** Ansible, PowerShell, Python, YAML.

---

### Task 1: Fix scvmm_job_info.py documentation and return syntax

**Files:**
- Modify: `plugins/modules/scvmm_job_info.py`

- [ ] **Step 1: Identify and fix unknown escape character in RETURN**
  The error is at line 74, column 23/24. Looking at the file, line 74 is inside the `RETURN` block.
  `sample: "CONTOSO\Admin"` contains a backslash that needs to be escaped or the string needs to be raw (it is already raw, but YAML parsing inside raw strings can still be tricky if not handled correctly).
  Wait, `RETURN = r'''` is used. However, the error says `found unknown escape character 'A'`. This means `\A` is being interpreted.

- [ ] **Step 2: Update RETURN block**
  Change `"CONTOSO\Admin"` to `"CONTOSO\\Admin"`.

- [ ] **Step 3: Verify fix**
  Run: `ansible-test sanity --docker default plugins/modules/scvmm_job_info.py`
  Expected: PASS

### Task 2: Fix scvmm_pxe_server.ps1 and scvmm_pxe_server_info.ps1

**Files:**
- Modify: `plugins/modules/scvmm_pxe_server.ps1`
- Modify: `plugins/modules/scvmm_pxe_server_info.ps1`

- [ ] **Step 1: Add shebang to scvmm_pxe_server.ps1**
  Add `#!powershell` as the first line.

- [ ] **Step 2: Fix long line and trailing whitespace in scvmm_pxe_server.ps1**
  Line 93 exceeds 160 chars. Line 100 has trailing whitespace.

- [ ] **Step 3: Add shebang to scvmm_pxe_server_info.ps1**
  Add `#!powershell` as the first line.

- [ ] **Step 4: Verify fix**
  Run: `ansible-test sanity --docker default plugins/modules/scvmm_pxe_server.ps1 plugins/modules/scvmm_pxe_server_info.ps1`
  Expected: PASS

### Task 3: Fix scvmm_servicing_window modules

**Files:**
- Modify: `plugins/modules/scvmm_servicing_window.ps1`
- Modify: `plugins/modules/scvmm_servicing_window.py`

- [ ] **Step 1: Fix PSPlaceCloseBrace in scvmm_servicing_window.ps1**
  Ensure `}` is on a new line before `else`, `catch`, or end of block at lines 73, 137, 148.

- [ ] **Step 2: Remove trailing whitespace in scvmm_servicing_window.ps1**
  Line 107.

- [ ] **Step 3: Synchronize weekly_recurrence argument_spec**
  Update `scvmm_servicing_window.ps1`'s `$spec` to include `choices` for `weekly_recurrence` to match `scvmm_servicing_window.py`.

- [ ] **Step 4: Verify fix**
  Run: `ansible-test sanity --docker default plugins/modules/scvmm_servicing_window.ps1 plugins/modules/scvmm_servicing_window.py`
  Expected: PASS

### Task 4: Final Verification

- [ ] **Step 1: Run sanity tests for all modified modules**
  Run: `ansible-test sanity --docker default plugins/modules/scvmm_job_info.py plugins/modules/scvmm_pxe_server.ps1 plugins/modules/scvmm_pxe_server_info.ps1 plugins/modules/scvmm_servicing_window.ps1 plugins/modules/scvmm_servicing_window.py`
  Expected: ALL PASS
