#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_virtual_hard_disk_info
short_description: Gather information about SCVMM Virtual Hard Disks
description:
  - Gather information about System Center Virtual Machine Manager (SCVMM) Virtual Hard Disks.
  - Wraps the Get-SCVirtualHardDisk cmdlet.
options:
  name:
    description:
      - The name of the virtual hard disk to retrieve info for.
    type: str
  vmm_server:
    description:
      - The name of the VMM server to connect to.
    type: str
author:
  - Steve Fulmer (@stevefulmer)
'''

EXAMPLES = r'''
- name: Get info for a specific VHD
  microsoft.scvmm.scvmm_virtual_hard_disk_info:
    name: "MyVHD.vhdx"

- name: Get info for all VHDs on a specific VMM server
  microsoft.scvmm.scvmm_virtual_hard_disk_info:
    vmm_server: "VMMServer01"
'''

RETURN = r'''
virtual_hard_disks:
  description: A list of SCVMM Virtual Hard Disks matching the criteria.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: The name of the virtual hard disk.
      type: str
      sample: "MyVHD.vhdx"
    id:
      description: The unique identifier of the virtual hard disk.
      type: str
      sample: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
    file_name:
      description: The file name of the virtual hard disk.
      type: str
      sample: "MyVHD.vhdx"
    size:
      description: The size of the virtual hard disk in bytes.
      type: int
      sample: 42949672960
    maximum_size:
      description: The maximum size of the virtual hard disk in bytes.
      type: int
      sample: 42949672960
    vhd_type:
      description: The type of the virtual hard disk (Dynamic, Fixed, Differencing).
      type: str
      sample: "Dynamic"
    host_path:
      description: The path to the virtual hard disk file on the host.
      type: str
      sample: "C:\\VMs\\MyVHD.vhdx"
    library_server:
      description: The name of the library server where the virtual hard disk is stored.
      type: str
      sample: "LibServer01"
    operating_system:
      description: The name of the operating system on the virtual hard disk.
      type: str
      sample: "64-bit edition of Windows Server 2022 Datacenter"
    enabled:
      description: Whether the virtual hard disk is enabled.
      type: bool
      sample: true
    description:
      description: The description of the virtual hard disk.
      type: str
      sample: "My VHD description"
    owner:
      description: The owner of the virtual hard disk.
      type: str
      sample: "CONTOSO\\User01"
    virtualization_platform:
      description: The virtualization platform of the virtual hard disk.
      type: str
      sample: "HyperV"
'''
