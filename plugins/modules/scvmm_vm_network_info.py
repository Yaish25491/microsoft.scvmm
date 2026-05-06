#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_vm_network_info
short_description: Gather information about SCVMM VM Networks
description:
  - Gather information about Virtual Machine Networks in Microsoft System Center Virtual Machine Manager (SCVMM).
author:
  - Steve Fulmer (@steve-fulmer)
options:
  name:
    description:
      - Name of the VM Network to gather information about.
      - If not specified, information about all VM Networks will be returned.
    type: str
'''

EXAMPLES = r'''
- name: Gather information about all VM Networks
  microsoft.scvmm.scvmm_vm_network_info:

- name: Gather information about a specific VM Network
  microsoft.scvmm.scvmm_vm_network_info:
    name: MyVMNetwork
'''

RETURN = r'''
vm_networks:
  description: List of VM Networks and their properties.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: Name of the VM Network.
      type: str
    id:
      description: Identifier of the VM Network.
      type: str
    description:
      description: Description of the VM Network.
      type: str
    logical_network:
      description: Name of the associated logical network.
      type: str
    isolation_type:
      description: The isolation type of the VM Network.
      type: str
    vm_network_type:
      description: The type of the VM Network.
      type: str
    ipv4_pa_address_pool_type:
      description: The IPv4 PA address pool type.
      type: str
    ipv6_pa_address_pool_type:
      description: The IPv6 PA address pool type.
      type: str
'''
