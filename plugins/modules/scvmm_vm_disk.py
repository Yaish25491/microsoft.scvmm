#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_vm_disk
short_description: Manage SCVMM VM Disks
description:
  - Manage virtual hard disks attached to a System Center Virtual Machine Manager (SCVMM) Virtual Machine.
  - Wraps the New-SCVirtualDiskDrive, Set-SCVirtualDiskDrive, and Remove-SCVirtualDiskDrive cmdlets.
options:
  vm_name:
    description:
      - The name of the virtual machine.
    type: str
    required: true
  name:
    description:
      - The name of the virtual disk drive.
    type: str
  bus:
    description:
      - The IDE or SCSI bus number.
    type: int
    default: 0
  lun:
    description:
      - The LUN (Logical Unit Number) of the drive.
    type: int
  virtual_hard_disk:
    description:
      - The name of an existing virtual hard disk in the library to attach.
    type: str
  size:
    description:
      - The size of a new virtual hard disk to create (in MB or GB depending on SCVMM).
    type: int
  dynamic:
    description:
      - Whether the newly created VHD should be dynamic.
    type: bool
    default: true
  state:
    description:
      - The desired state of the virtual disk drive.
    type: str
    choices: [absent, present]
    default: present
  vmm_server:
    description:
      - The name of the VMM server.
    type: str
author:
  - Steve Fulmer (@stevefulme1)
'''

EXAMPLES = r'''
- name: Add a virtual disk to a VM
  microsoft.scvmm.scvmm_vm_disk:
    vm_name: "MyVM"
    bus: 0
    lun: 1
    size: 20480
    state: present
'''

RETURN = r'''
vm_disk:
  description: Information about the virtual disk drive.
  returned: always
  type: dict
'''
