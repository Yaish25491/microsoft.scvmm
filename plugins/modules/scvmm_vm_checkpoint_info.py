# -*- coding: utf-8 -*-

# Copyright: (c) 2024, Microsoft Corporation
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_vm_checkpoint_info
short_description: Gather information about virtual machine checkpoints in System Center Virtual Machine Manager (SCVMM).
description:
  - Gather information about virtual machine checkpoints in System Center Virtual Machine Manager (SCVMM).
  - This module uses the SCVMM PowerShell cmdlet Get-SCVMCheckpoint.
version_added: "1.0.0"
author:
  - Jarvis Framework (@jarvis)
options:
  name:
    description:
      - The name of the checkpoint to gather information about.
    type: str
  vm_name:
    description:
      - The name of the virtual machine to gather checkpoint information for.
    type: str
  vmm_server:
    description:
      - The VMM server to connect to.
    type: str
'''

EXAMPLES = r'''
- name: Get all checkpoints for all VMs
  microsoft.scvmm.scvmm_vm_checkpoint_info:

- name: Get all checkpoints for a specific VM
  microsoft.scvmm.scvmm_vm_checkpoint_info:
    vm_name: "TestVM01"

- name: Get a specific checkpoint by name for a specific VM
  microsoft.scvmm.scvmm_vm_checkpoint_info:
    vm_name: "TestVM01"
    name: "Before Update"
'''

RETURN = r'''
checkpoints:
  description: A list of checkpoints found.
  returned: always
  type: list
  elements: dict
  sample:
    - name: "Before Update"
      description: "Checkpoint taken before applying updates"
      added_time: "2024-05-20T10:00:00Z"
      id: "550e8400-e29b-41d4-a716-446655440000"
      vm_name: "TestVM01"
      is_latest: true
'''
