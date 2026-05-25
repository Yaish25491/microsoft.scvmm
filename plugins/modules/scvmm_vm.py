#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_vm
short_description: Manage SCVMM Virtual Machines
description:
  - Manage the lifecycle of System Center Virtual Machine Manager (SCVMM) Virtual Machines.
  - Wraps the New-SCVirtualMachine, Set-SCVirtualMachine, Remove-SCVirtualMachine, and Get-SCVirtualMachine cmdlets.
options:
  name:
    description:
      - The name of the virtual machine.
    type: str
    required: true
  state:
    description:
      - The desired state of the virtual machine.
    type: str
    choices: [absent, present]
    default: present
  host_group:
    description:
      - The name of the host group where the virtual machine will reside.
      - Used when creating a new virtual machine.
    type: str
  cloud:
    description:
      - The name of the cloud where the virtual machine will reside.
      - Used when creating a new virtual machine.
    type: str
  description:
    description:
      - The description of the virtual machine.
    type: str
  memory_mb:
    description:
      - The amount of memory assigned to the VM in MB.
    type: int
  cpu_count:
    description:
      - The number of CPUs assigned to the VM.
    type: int
  vmm_server:
    description:
      - The name of the VMM server to connect to.
    type: str
author:
  - Steve Fulmer (@stevefulme1)
'''

EXAMPLES = r'''
- name: Create a virtual machine in a host group
  microsoft.scvmm.scvmm_vm:
    name: "MyVM"
    state: present
    host_group: "All Hosts\\MyHostGroup"
    description: "Created by Ansible"
    memory_mb: 2048
    cpu_count: 2

- name: Create a virtual machine in a cloud
  microsoft.scvmm.scvmm_vm:
    name: "MyCloudVM"
    state: present
    cloud: "MyCloud"
    memory_mb: 4096
    cpu_count: 4

- name: Update virtual machine description and memory
  microsoft.scvmm.scvmm_vm:
    name: "MyVM"
    state: present
    description: "Updated description"
    memory_mb: 4096

- name: Remove a virtual machine
  microsoft.scvmm.scvmm_vm:
    name: "MyVM"
    state: absent
'''

RETURN = r'''
vm:
  description: Information about the virtual machine.
  returned: always
  type: dict
  contains:
    name:
      description: The name of the virtual machine.
      type: str
      sample: "MyVM"
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
      sample: "My test VM"
'''
