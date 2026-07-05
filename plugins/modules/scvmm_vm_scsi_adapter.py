#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2025, Microsoft Corporation
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: scvmm_vm_scsi_adapter
short_description: Manage virtual SCSI adapters on SCVMM virtual machines
description:
  - Create, update, or remove virtual SCSI adapters on SCVMM virtual machines.
  - Supports shared SCSI adapters for clustering scenarios.
  - SCSI adapters are identified by adapter_id (0-3).
options:
  vm_name:
    description:
      - Name of the virtual machine to manage SCSI adapters on.
    type: str
    required: true
  state:
    description:
      - Desired state of the SCSI adapter.
      - C(present) ensures the SCSI adapter exists with specified configuration.
      - C(absent) ensures the SCSI adapter is removed.
    type: str
    choices: [ present, absent ]
    default: present
  vmm_server:
    description:
      - SCVMM server hostname or IP address.
      - If not specified, uses the default SCVMM server connection.
    type: str
  adapter_id:
    description:
      - SCSI adapter slot/ID number (0-3).
      - If not specified when state is present, the next available slot is used.
      - Required when state is absent.
    type: int
  shared:
    description:
      - Enable shared SCSI adapter for clustering scenarios.
      - Only applicable when state is present.
    type: bool
    default: false
notes:
  - This module requires the VirtualMachineManager PowerShell module.
  - Check mode is supported.
author:
  - Ansible Cloud Team (@ansible)
'''

EXAMPLES = r'''
- name: Add SCSI adapter to VM
  microsoft.scvmm.scvmm_vm_scsi_adapter:
    vm_name: TestVM01
    state: present
    vmm_server: scvmm01.contoso.com

- name: Add shared SCSI adapter for clustering
  microsoft.scvmm.scvmm_vm_scsi_adapter:
    vm_name: ClusterVM01
    state: present
    adapter_id: 1
    shared: true
    vmm_server: scvmm01.contoso.com

- name: Remove SCSI adapter from VM
  microsoft.scvmm.scvmm_vm_scsi_adapter:
    vm_name: TestVM01
    state: absent
    adapter_id: 1
    vmm_server: scvmm01.contoso.com

- name: Ensure SCSI adapter is not shared
  microsoft.scvmm.scvmm_vm_scsi_adapter:
    vm_name: TestVM01
    state: present
    adapter_id: 0
    shared: false
'''

RETURN = r'''
vm_name:
  description: Name of the virtual machine.
  returned: always
  type: str
  sample: TestVM01
state:
  description: State of the SCSI adapter.
  returned: always
  type: str
  sample: present
scsi_adapter:
  description: Details of the SCSI adapter.
  returned: when state is present
  type: dict
  contains:
    id:
      description: Unique identifier of the SCSI adapter.
      type: str
      sample: "12345678-1234-1234-1234-123456789012"
    adapter_id:
      description: SCSI adapter slot/ID number.
      type: int
      sample: 0
    shared:
      description: Whether the SCSI adapter is shared.
      type: bool
      sample: false
'''
