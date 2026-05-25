#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_vm_info
short_description: Gather information about SCVMM VMs
description:
  - Gather information about System Center Virtual Machine Manager (SCVMM) Virtual Machines.
  - Wraps the Get-SCVirtualMachine cmdlet.
options:
  name:
    description:
      - The name of the virtual machine to retrieve info for.
    type: str
  host:
    description:
      - The host name where the virtual machine resides.
    type: str
  cloud:
    description:
      - The name of the cloud where the virtual machine resides.
    type: str
author:
  - Ansible Community (@ansible-community)
'''

EXAMPLES = r'''
- name: Get info for a specific VM
  microsoft.scvmm.scvmm_vm_info:
    name: "MyVM"

- name: Get info for all VMs on a specific host
  microsoft.scvmm.scvmm_vm_info:
    host: "MyHost"

- name: Get info for all VMs in a cloud
  microsoft.scvmm.scvmm_vm_info:
    cloud: "MyCloud"
'''

RETURN = r'''
vms:
  description: A list of SCVMM Virtual Machines matching the criteria.
  returned: always
  type: list
  elements: dict
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
      sample: "Running"
    cpu_count:
      description: The number of CPUs assigned to the VM.
      type: int
      sample: 2
    memory:
      description: The amount of memory assigned to the VM in MB.
      type: int
      sample: 4096
    host_name:
      description: The name of the host where the VM resides.
      type: str
      sample: "Host01"
    cloud:
      description: The name of the cloud where the VM resides.
      type: str
      sample: "Cloud01"
'''
