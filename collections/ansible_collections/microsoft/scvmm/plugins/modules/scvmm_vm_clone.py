#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_vm_clone
short_description: Clone an existing SCVMM Virtual Machine
description:
  - Clone an existing System Center Virtual Machine Manager (SCVMM) Virtual Machine.
  - Wraps the New-SCVirtualMachine cmdlet with the -VM parameter.
options:
  name:
    description:
      - The name of the source virtual machine to clone.
    type: str
    required: true
  new_name:
    description:
      - The name of the new virtual machine to be created.
    type: str
    required: true
  state:
    description:
      - The desired state of the new virtual machine.
      - Currently only supports C(present) to ensure the clone exists.
    type: str
    choices: [present]
    default: present
  vm_host:
    description:
      - The name of the host where the cloned virtual machine will reside.
      - Mutually exclusive with I(cloud).
    type: str
  cloud:
    description:
      - The name of the cloud where the cloned virtual machine will reside.
      - Mutually exclusive with I(vm_host).
    type: str
  path:
    description:
      - The path on the destination host for the virtual machine files.
      - Required when I(vm_host) is specified.
    type: str
  description:
    description:
      - The description of the new virtual machine.
    type: str
  vmm_server:
    description:
      - The name of the VMM server to connect to.
    type: str
author:
  - Steve Fulmer (@stevefulme1)
'''

EXAMPLES = r'''
- name: Clone a virtual machine to a specific host
  microsoft.scvmm.scvmm_vm_clone:
    name: "SourceVM"
    new_name: "CloneVM01"
    vm_host: "Host01.contoso.com"
    path: "D:\\VirtualMachines"
    description: "Cloned by Ansible"

- name: Clone a virtual machine to a cloud
  microsoft.scvmm.scvmm_vm_clone:
    name: "SourceVM"
    new_name: "CloneVM02"
    cloud: "ProductionCloud"
'''

RETURN = r'''
vm:
  description: Information about the new cloned virtual machine.
  returned: always
  type: dict
  contains:
    name:
      description: The name of the virtual machine.
      type: str
      sample: "CloneVM01"
    id:
      description: The unique identifier of the virtual machine.
      type: str
      sample: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
    status:
      description: The current status of the virtual machine.
      type: str
      sample: "PowerOff"
    cpu_count:
      description: The number of CPUs assigned to the VM.
      type: int
      sample: 2
    memory:
      description: The amount of memory assigned to the VM in MB.
      type: int
      sample: 2048
    description:
      description: The description of the virtual machine.
      type: str
      sample: "Cloned from SourceVM"
'''
