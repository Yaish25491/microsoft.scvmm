#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2024, Ansible Project
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_vm_checkpoint_info
short_description: Gather information about SCVMM VM checkpoints
description:
  - Gather information about System Center Virtual Machine Manager (SCVMM) Virtual Machine checkpoints.
  - Wraps the Get-SCVMCheckpoint cmdlet.
options:
  name:
    description:
      - The name of the checkpoint to retrieve info for.
      - This can be a glob pattern.
    type: str
  vm_name:
    description:
      - The name of the virtual machine to retrieve checkpoints for.
    type: str
author:
  - Ansible Community (@ansible-community)
'''

EXAMPLES = r'''
- name: Get info for all checkpoints of a specific VM
  microsoft.scvmm.scvmm_vm_checkpoint_info:
    vm_name: "MyVM"

- name: Get info for a specific checkpoint by name across all VMs
  microsoft.scvmm.scvmm_vm_checkpoint_info:
    name: "Before Update"

- name: Get info for a specific checkpoint of a specific VM
  microsoft.scvmm.scvmm_vm_checkpoint_info:
    vm_name: "MyVM"
    name: "Specific Checkpoint"
'''

RETURN = r'''
checkpoints:
  description: A list of SCVMM VM checkpoints matching the criteria.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: The name of the checkpoint.
      type: str
      sample: "Before Update"
    id:
      description: The unique identifier of the checkpoint.
      type: str
      sample: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
    description:
      description: The description of the checkpoint.
      type: str
      sample: "Checkpoint taken before patching"
    added_time:
      description: The time when the checkpoint was added.
      type: str
      sample: "2024-05-20T10:00:00"
    vm_name:
      description: The name of the virtual machine the checkpoint belongs to.
      type: str
      sample: "MyVM"
    vm_id:
      description: The unique identifier of the virtual machine.
      type: str
      sample: "b2c3d4e5-f6a7-8901-bcde-f12345678901"
    is_parent:
      description: Whether this checkpoint is a parent checkpoint.
      type: bool
      sample: true
    parent_checkpoint_id:
      description: The unique identifier of the parent checkpoint, if any.
      type: str
      sample: "c3d4e5f6-a7b8-9012-cdef-123456789012"
'''
