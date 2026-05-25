#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_storage_file_share_info
short_description: Gather information about SCVMM Storage File Shares
description:
  - Gather information about System Center Virtual Machine Manager (SCVMM) Storage File Shares.
  - This module wraps the C(Get-SCStorageFileShare) PowerShell cmdlet.
version_added: "1.0.0"
author:
  - Gemini (@gemini)
options:
  name:
    description:
      - The name of the SCVMM Storage File Share to filter by.
    type: str
'''

EXAMPLES = r'''
- name: Gather information about all Storage File Shares
  microsoft.scvmm.scvmm_storage_file_share_info:

- name: Gather information about a specific Storage File Share by name
  microsoft.scvmm.scvmm_storage_file_share_info:
    name: "Share01"
'''

RETURN = r'''
storage_file_shares:
  description: A list of dictionaries containing information about the SCVMM Storage File Shares.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: The name of the storage file share.
      type: str
      sample: "Share01"
    id:
      description: The unique identifier (GUID) of the storage file share.
      type: str
      sample: "12345678-1234-1234-1234-123456789012"
    path:
      description: The full network path of the storage file share.
      type: str
      sample: "\\\\Server01\\Share01"
    description:
      description: The description of the storage file share.
      type: str
      sample: "High speed storage share"
    storage_classification:
      description: The storage classification assigned to the file share.
      type: str
      sample: "Gold"
    capacity:
      description: The total capacity of the file share in bytes.
      type: int
      sample: 1099511627776
    free_space:
      description: The available free space on the file share in bytes.
      type: int
      sample: 536870912000
    is_available_for_placement:
      description: Indicates if the file share is available for VM placement.
      type: bool
      sample: true
    storage_file_server:
      description: The name of the storage file server hosting this share.
      type: str
      sample: "FileServer01"
    vm_host:
      description: The name of the VM host associated with this share.
      type: str
      sample: "Host01"
    library_server:
      description: The name of the library server associated with this share.
      type: str
      sample: "LibraryServer01"
'''
