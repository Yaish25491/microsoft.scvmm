#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_ip_pool
short_description: Manage SCVMM Static IP Address Pools
description:
  - Manage the lifecycle of Static IP Address Pools in System Center Virtual Machine Manager (SCVMM).
  - Wraps New-SCStaticIPAddressPool, Set-SCStaticIPAddressPool, and Remove-SCStaticIPAddressPool.
options:
  name:
    description:
      - The name of the IP pool.
    type: str
    required: true
  logical_network_definition:
    description:
      - The name of the logical network definition (network site) to which this pool belongs.
      - Required for creation.
    type: str
  ip_address_range_start:
    description:
      - The start of the IP address range.
    type: str
  ip_address_range_end:
    description:
      - The end of the IP address range.
    type: str
  description:
    description:
      - The description of the IP pool.
    type: str
  state:
    description:
      - The desired state of the IP pool.
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
- name: Create a static IP pool
  microsoft.scvmm.scvmm_ip_pool:
    name: "MyIPPool"
    logical_network_definition: "MyNetworkSite"
    ip_address_range_start: "10.0.0.10"
    ip_address_range_end: "10.0.0.100"
    state: present
'''

RETURN = r'''
ip_pool:
  description: Information about the IP pool.
  returned: always
  type: dict
'''
