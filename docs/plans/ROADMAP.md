# microsoft.scvmm Collection Roadmap

This document outlines the planned modules for the `microsoft.scvmm` collection as per Jira ANSTRAT-2120.

## Phase 1: Core Modules
- [ ] `scvmm_vm` (VM Lifecycle: Create, start, stop, restart, delete)
- [ ] `scvmm_vm_info` (Retrieve details about VMs)
- [ ] `scvmm_vm_template` (Create and deploy VM templates)
- [ ] `scvmm_cloud` (Manage SCVMM private clouds)

## Phase 2: Infrastructure & Discovery
- [ ] `scvmm_host_group` (Manage host groups)
- [ ] `scvmm_host_info` (Inventory/gather facts on Hyper-V hosts)
- [ ] `scvmm_logical_network` (Create/manage logical networks)
- [ ] `scvmm_vm_network` (Create/manage VM networks)

## Phase 3: Storage & Networking Isolation
- [ ] `scvmm_network_isolation` (Manage isolation boundaries)
- [ ] `scvmm_vhd` (Manage Virtual Hard Disks)
- [ ] `scvmm_storage_classification` (Manage storage classes)

## Phase 4: Advanced Day 2 Operations
- [ ] `scvmm_checkpoint` (Create/restore/remove checkpoints)
- [ ] `scvmm_availability_set` (Manage VM availability sets)
- [ ] `scvmm_vm_hardware` (Modify CPU, Memory, attach/detach storage post-creation)

## Utilities
- [ ] `plugins/module_utils/SCVMM.psm1` (Core connection/conversion utility)
