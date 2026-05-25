#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_storage_provider_info
short_description: Gather information about SCVMM Storage Providers
description:
  - Gather information about System Center Virtual Machine Manager (SCVMM) Storage Providers.
  - This module wraps the C(Get-SCStorageProvider) PowerShell cmdlet.
version_added: "1.0.0"
author:
  - Gemini (@gemini)
options:
  name:
    description:
      - The name of the SCVMM Storage Provider to filter by.
    type: str
'''

EXAMPLES = r'''
- name: Gather information about all Storage Providers
  microsoft.scvmm.scvmm_storage_provider_info:

- name: Gather information about a specific Storage Provider by name
  microsoft.scvmm.scvmm_storage_provider_info:
    name: "Provider01"
'''

RETURN = r'''
storage_providers:
  description: A list of dictionaries containing information about the SCVMM Storage Providers.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: The name of the storage provider.
      type: str
      sample: "Provider01"
    id:
      description: The unique identifier (GUID) of the storage provider.
      type: str
      sample: "12345678-1234-1234-1234-123456789012"
    description:
      description: The description of the storage provider.
      type: str
      sample: "SMI-S Provider for Array01"
    type:
      description: The type of storage provider.
      type: str
      sample: "SMIS"
    network_device_name:
      description: The network name or IP address of the storage provider.
      type: str
      sample: "10.0.0.50"
    manufacturer:
      description: The manufacturer of the storage provider.
      type: str
      sample: "Dell"
    model:
      description: The model of the storage provider.
      type: str
      sample: "PowerStore"
    is_active:
      description: Indicates if the storage provider is active.
      type: bool
      sample: true
    state:
      description: The state of the storage provider.
      type: str
      sample: "Responding"
    tcp_port:
      description: The TCP port used to connect to the storage provider.
      type: int
      sample: 5988
'''
