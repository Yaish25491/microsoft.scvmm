#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_mac_address_pool_info
short_description: Gather information about SCVMM MAC address pools
description:
  - Gather information about System Center Virtual Machine Manager (SCVMM) MAC address pools.
  - Wraps the Get-SCMACAddressPool cmdlet.
options:
  name:
    description:
      - The name of the MAC address pool to retrieve info for.
      - If not specified, all MAC address pools are returned.
    type: str
author:
  - Ansible Community (@ansible-community)
'''

EXAMPLES = r'''
- name: Get info for a specific MAC address pool
  microsoft.scvmm.scvmm_mac_address_pool_info:
    name: "MAC Address Pool 01"

- name: Get info for all MAC address pools
  microsoft.scvmm.scvmm_mac_address_pool_info:
'''

RETURN = r'''
mac_address_pools:
  description: A list of SCVMM MAC address pools matching the criteria.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: The name of the MAC address pool.
      type: str
      sample: "MAC Address Pool 01"
    id:
      description: The unique identifier of the MAC address pool.
      type: str
      sample: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
    description:
      description: The description of the MAC address pool.
      type: str
      sample: "Production MAC address pool"
    mac_address_range_start:
      description: The first MAC address in the pool range.
      type: str
      sample: "00-1D-D8-B7-1C-00"
    mac_address_range_end:
      description: The last MAC address in the pool range.
      type: str
      sample: "00-1D-D8-F4-1F-FF"
    host_groups:
      description: The list of host groups associated with the MAC address pool.
      type: list
      elements: str
      sample: ["All Hosts", "Production"]
'''
