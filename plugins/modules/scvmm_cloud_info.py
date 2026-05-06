#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2024, Ansible Project
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_cloud_info
short_description: Gather information about SCVMM Private Clouds
description:
  - Gather information about System Center Virtual Machine Manager (SCVMM) Private Clouds.
  - This module wraps the C(Get-SCCloud) PowerShell cmdlet.
version_added: "1.0.0"
author:
  - Gemini (@gemini)
options:
  name:
    description:
      - The name of the SCVMM Private Cloud to filter by.
    type: str
'''

EXAMPLES = r'''
- name: Gather information about all Private Clouds
  microsoft.scvmm.scvmm_cloud_info:

- name: Gather information about a specific Private Cloud by name
  microsoft.scvmm.scvmm_cloud_info:
    name: "Cloud01"
'''

RETURN = r'''
clouds:
  description: A list of dictionaries containing information about the SCVMM Private Clouds.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: The name of the private cloud.
      type: str
      sample: "Cloud01"
    id:
      description: The unique identifier (GUID) of the private cloud.
      type: str
      sample: "12345678-1234-1234-1234-123456789012"
    description:
      description: The description of the private cloud.
      type: str
      sample: "Main datacenter private cloud"
    host_groups:
      description: A list of host groups associated with the private cloud.
      type: list
      elements: str
      sample: ["All Hosts\\Datacenter01"]
    read_only_library_shares:
      description: A list of read-only library shares available to the private cloud.
      type: list
      elements: str
    read_write_library_path:
      description: The path for storing virtual machines created in the cloud.
      type: str
    capability_profiles:
      description: A list of hardware capability profiles assigned to the cloud.
      type: list
      elements: str
'''
