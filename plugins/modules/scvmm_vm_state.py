#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_vm_state
short_description: Manage VM power state in SCVMM
description:
  - Manage the power state of System Center Virtual Machine Manager (SCVMM) Virtual Machines.
  - Supports starting, stopping, and suspending virtual machines.
options:
  name:
    description:
      - The name of the virtual machine to manage.
    type: str
    required: true
  vmm_server:
    description:
      - The VMM server to connect to.
    type: str
    required: true
  state:
    description:
      - The desired power state of the virtual machine.
      - Use C(started) to ensure the VM is running.
      - Use C(stopped) to power off the VM.
      - Use C(suspended) to pause the VM.
    type: str
    required: true
    choices: [ started, stopped, suspended ]
  force:
    description:
      - If C(true), the VM will be stopped forcefully (equivalent to pulling the power).
      - If C(false), a graceful shutdown will be attempted.
      - Only applicable when I(state=stopped).
    type: bool
    default: false
author:
  - Ansible Community (@ansible-community)
'''

EXAMPLES = r'''
- name: Start a virtual machine
  microsoft.scvmm.scvmm_vm_state:
    name: "MyVM"
    vmm_server: "vmm01.example.com"
    state: started

- name: Stop a virtual machine gracefully
  microsoft.scvmm.scvmm_vm_state:
    name: "MyVM"
    vmm_server: "vmm01.example.com"
    state: stopped

- name: Forcefully stop a virtual machine
  microsoft.scvmm.scvmm_vm_state:
    name: "MyVM"
    vmm_server: "vmm01.example.com"
    state: stopped
    force: true

- name: Suspend a virtual machine
  microsoft.scvmm.scvmm_vm_state:
    name: "MyVM"
    vmm_server: "vmm01.example.com"
    state: suspended
'''

RETURN = r'''
vm_name:
  description: The name of the virtual machine.
  returned: always
  type: str
  sample: "MyVM"
state:
  description: The status of the virtual machine after the operation.
  returned: always
  type: str
  sample: "Running"
'''
