# -*- coding: utf-8 -*-

# Copyright: (c) 2024, Microsoft Corporation
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_vm_checkpoint
short_description: Manage virtual machine checkpoints in System Center Virtual Machine Manager (SCVMM).
description:
  - Create, modify, restore, or remove virtual machine checkpoints in System Center Virtual Machine Manager (SCVMM).
  - This module uses the SCVMM PowerShell cmdlets New-SCVMCheckpoint, Set-SCVMCheckpoint, Restore-SCVMCheckpoint, and Remove-SCVMCheckpoint.
version_added: "1.0.0"
author:
  - Jarvis Framework (@jarvis)
options:
  name:
    description:
      - The name of the checkpoint.
      - Required when I(state=present) (for creation) or I(state=absent)/I(state=restored) to identify the checkpoint.
    type: str
  vm_name:
    description:
      - The name of the virtual machine associated with the checkpoint.
    type: str
    required: true
  description:
    description:
      - A description for the checkpoint.
      - This can be set when creating or updating a checkpoint.
    type: str
  state:
    description:
      - The desired state of the checkpoint.
      - V(present) ensures the checkpoint exists with the specified name and description. If it exists but properties differ, it will be updated.
      - V(absent) ensures the checkpoint does not exist.
      - V(restored) ensures the virtual machine is restored to the specified checkpoint state.
    type: str
    default: present
    choices: [ present, absent, restored ]
'''

EXAMPLES = r'''
- name: Create a new checkpoint for a VM
  microsoft.scvmm.scvmm_vm_checkpoint:
    name: "Before Update"
    vm_name: "TestVM01"
    description: "Checkpoint taken before applying updates"
    state: present

- name: Update the description of an existing checkpoint
  microsoft.scvmm.scvmm_vm_checkpoint:
    name: "Before Update"
    vm_name: "TestVM01"
    description: "Updated description"
    state: present

- name: Restore a VM to a specific checkpoint
  microsoft.scvmm.scvmm_vm_checkpoint:
    name: "Before Update"
    vm_name: "TestVM01"
    state: restored

- name: Remove a checkpoint
  microsoft.scvmm.scvmm_vm_checkpoint:
    name: "Before Update"
    vm_name: "TestVM01"
    state: absent
'''

RETURN = r'''
checkpoint:
  description: The properties of the checkpoint after the operation.
  returned: success
  type: dict
  sample:
    name: "Before Update"
    description: "Checkpoint taken before applying updates"
    added_time: "2024-05-20T10:00:00Z"
    checkpoint_id: "550e8400-e29b-41d4-a716-446655440000"
    vm_name: "TestVM01"
    is_latest: true
'''
