# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_vm_dvd_drive
short_description: Manage virtual DVD drives on a virtual machine in SCVMM.
description:
    - Manage virtual DVD drives on a virtual machine in System Center Virtual Machine Manager (SCVMM).
    - Can create, modify, and remove virtual DVD drives.
    - Can mount or unmount ISO images.
author:
    - Steve Fulmer (@steve-fulmer)
options:
    vm:
        description:
            - The name of the virtual machine.
        type: str
        required: true
    bus:
        description:
            - The IDE bus number for the DVD drive (0 or 1).
            - Required when creating a new DVD drive if not using I(lun).
        type: int
    lun:
        description:
            - The IDE Logical Unit Number (LUN) for the DVD drive (0 or 1).
            - Required when creating a new DVD drive if not using I(bus).
        type: int
    iso:
        description:
            - The name of the ISO image to mount from the SCVMM library.
            - If provided, the module will attempt to mount this ISO.
            - If set to an empty string and I(no_media) is not provided, it will unmount any existing media.
        type: str
    no_media:
        description:
            - If set to C(true), ensures no media is attached to the DVD drive.
        type: bool
        default: false
    state:
        description:
            - The desired state of the virtual DVD drive.
            - C(present) ensures the drive exists with the specified configuration.
            - C(absent) ensures the drive is removed.
        type: str
        choices: [ present, absent ]
        default: present
'''

EXAMPLES = r'''
- name: Add a DVD drive to a VM
  microsoft.scvmm.scvmm_vm_dvd_drive:
    vm: VM01
    bus: 1
    lun: 0
    state: present

- name: Mount an ISO to an existing DVD drive
  microsoft.scvmm.scvmm_vm_dvd_drive:
    vm: VM01
    bus: 1
    lun: 0
    iso: WindowsServer2022.iso

- name: Unmount media from a DVD drive
  microsoft.scvmm.scvmm_vm_dvd_drive:
    vm: VM01
    bus: 1
    lun: 0
    no_media: true

- name: Remove a DVD drive from a VM
  microsoft.scvmm.scvmm_vm_dvd_drive:
    vm: VM01
    bus: 1
    lun: 0
    state: absent
'''

RETURN = r'''
dvd_drive:
    description: Details about the virtual DVD drive.
    returned: always
    type: dict
    sample: {
        "bus": 1,
        "lun": 0,
        "iso": "WindowsServer2022.iso",
        "name": "Virtual DVD drive",
        "id": "550e8400-e29b-41d4-a716-446655440000"
    }
'''
