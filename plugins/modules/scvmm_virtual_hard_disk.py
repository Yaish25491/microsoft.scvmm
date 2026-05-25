#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_virtual_hard_disk
short_description: Manage SCVMM Virtual Hard Disks
description:
  - Manage the lifecycle of System Center Virtual Machine Manager (SCVMM) Virtual Hard Disks.
  - Wraps the New-SCVirtualHardDisk, Set-SCVirtualHardDisk, Remove-SCVirtualHardDisk, and Get-SCVirtualHardDisk cmdlets.
options:
  name:
    description:
      - The display name of the virtual hard disk.
    type: str
    required: true
  state:
    description:
      - The desired state of the virtual hard disk.
    type: str
    choices: [absent, present]
    default: present
  file_name:
    description:
      - The file name of the virtual hard disk (e.g., C(disk01.vhdx)).
      - Required when creating a new virtual hard disk.
    type: str
  size_mb:
    description:
      - The size of the virtual hard disk in MB.
      - Required when creating a new virtual hard disk.
    type: int
  dynamic:
    description:
      - Specifies that the virtual hard disk is dynamic.
    type: bool
    default: true
  fixed:
    description:
      - Specifies that the virtual hard disk is fixed.
    type: bool
  library_server:
    description:
      - The name of the library server where the virtual hard disk will be stored.
      - Required when creating a new virtual hard disk.
    type: str
  share_path:
    description:
      - The library share path where the virtual hard disk will be stored.
      - Required when creating a new virtual hard disk.
    type: str
  description:
    description:
      - The description of the virtual hard disk.
    type: str
  owner:
    description:
      - The owner of the virtual hard disk.
    type: str
  enabled:
    description:
      - Whether the virtual hard disk is enabled.
    type: bool
  vmm_server:
    description:
      - The name of the VMM server to connect to.
    type: str
author:
  - Steve Fulmer (@stevefulmer)
'''

EXAMPLES = r'''
- name: Create a dynamic virtual hard disk in the library
  microsoft.scvmm.scvmm_virtual_hard_disk:
    name: "NewDisk01"
    file_name: "NewDisk01.vhdx"
    size_mb: 40960
    dynamic: true
    library_server: "LibServer01"
    share_path: "\\\\LibServer01\\MSSCVMMLibrary\\VHDs"
    state: present

- name: Update virtual hard disk description
  microsoft.scvmm.scvmm_virtual_hard_disk:
    name: "NewDisk01"
    description: "Updated description"
    state: present

- name: Remove a virtual hard disk
  microsoft.scvmm.scvmm_virtual_hard_disk:
    name: "NewDisk01"
    state: absent
'''

RETURN = r'''
virtual_hard_disk:
  description: Information about the virtual hard disk.
  returned: always
  type: dict
  contains:
    name:
      description: The name of the virtual hard disk.
      type: str
      sample: "NewDisk01"
    id:
      description: The unique identifier of the virtual hard disk.
      type: str
      sample: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
    file_name:
      description: The file name of the virtual hard disk.
      type: str
      sample: "NewDisk01.vhdx"
    size:
      description: The size of the virtual hard disk in bytes.
      type: int
      sample: 42949672960
    vhd_type:
      description: The type of the virtual hard disk.
      type: str
      sample: "Dynamic"
    description:
      description: The description of the virtual hard disk.
      type: str
      sample: "My VHD"
'''
