#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_host_group_info
short_description: Gather information about SCVMM Host Groups
description:
  - Gather information about System Center Virtual Machine Manager (SCVMM) Host Groups.
  - This module wraps the C(Get-SCVMHostGroup) PowerShell cmdlet.
version_added: "1.0.0"
author:
  - Gemini (@gemini)
options:
  name:
    description:
      - The name of the SCVMM Host Group to filter by.
    type: str
  path:
    description:
      - The path of the SCVMM Host Group to filter by (e.g., C(All Hosts\Datacenter01)).
    type: str
'''

EXAMPLES = r'''
- name: Gather information about all Host Groups
  microsoft.scvmm.scvmm_host_group_info:

- name: Gather information about a specific Host Group by name
  microsoft.scvmm.scvmm_host_group_info:
    name: "Datacenter01"

- name: Gather information about a specific Host Group by path
  microsoft.scvmm.scvmm_host_group_info:
    path: "All Hosts\\Datacenter01"
'''

RETURN = r'''
host_groups:
  description: A list of dictionaries containing information about the SCVMM Host Groups.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: The name of the host group.
      type: str
      sample: "Datacenter01"
    id:
      description: The unique identifier (GUID) of the host group.
      type: str
      sample: "12345678-1234-1234-1234-123456789012"
    path:
      description: The hierarchical path of the host group.
      type: str
      sample: "All Hosts\\Datacenter01"
    description:
      description: The description of the host group.
      type: str
      sample: "Main datacenter host group"
    parent_host_group:
      description: The name of the parent host group.
      type: str
      sample: "All Hosts"
'''
