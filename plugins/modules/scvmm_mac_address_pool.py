#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_mac_address_pool
short_description: Manage SCVMM MAC address pools
description:
  - Manage the lifecycle of System Center Virtual Machine Manager (SCVMM) MAC address pools.
  - Wraps the New-SCMACAddressPool, Set-SCMACAddressPool, and Remove-SCMACAddressPool cmdlets.
options:
  name:
    description:
      - The name of the MAC address pool.
    type: str
    required: true
  state:
    description:
      - The desired state of the MAC address pool.
    type: str
    choices: [absent, present]
    default: present
  description:
    description:
      - The description of the MAC address pool.
    type: str
  mac_address_range_start:
    description:
      - The first MAC address in the range of static MAC addresses.
      - Required when creating a new MAC address pool.
    type: str
  mac_address_range_end:
    description:
      - The last MAC address in the range of static MAC addresses.
      - Required when creating a new MAC address pool.
    type: str
  host_groups:
    description:
      - A list of host groups to associate with the MAC address pool.
      - Required when creating a new MAC address pool.
    type: list
    elements: str
author:
  - Ansible Community (@ansible-community)
'''

EXAMPLES = r'''
- name: Create a MAC address pool
  microsoft.scvmm.scvmm_mac_address_pool:
    name: "MAC Address Pool 01"
    state: present
    mac_address_range_start: "00-1D-D8-B7-1C-00"
    mac_address_range_end: "00-1D-D8-F4-1F-FF"
    host_groups: ["All Hosts"]
    description: "Production MAC address pool"

- name: Update MAC address pool description
  microsoft.scvmm.scvmm_mac_address_pool:
    name: "MAC Address Pool 01"
    state: present
    description: "Updated description"

- name: Remove a MAC address pool
  microsoft.scvmm.scvmm_mac_address_pool:
    name: "MAC Address Pool 01"
    state: absent
'''

RETURN = r'''
mac_address_pool:
  description: Information about the MAC address pool.
  returned: always
  type: dict
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
      sample: ["All Hosts"]
'''
