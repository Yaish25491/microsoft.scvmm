#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_host_network_adapter
short_description: Manage SCVMM Host Network Adapters
description:
  - Manage physical network adapters on a System Center Virtual Machine Manager (SCVMM) VM Host.
  - Currently supports assigning logical networks and IP address pools to adapters.
author:
  - Gemini CLI (@gemini)
options:
  vm_host:
    description:
      - The name of the VM Host.
    type: str
    required: true
  name:
    description:
      - The name of the physical network adapter.
    type: str
    required: true
  logical_network:
    description:
      - The name of the logical network to associate with the adapter.
    type: str
  ip_address_pool:
    description:
      - The name of the IP address pool to associate with the adapter.
    type: str
  state:
    description:
      - Desired state of the adapter.
    type: str
    choices: [ present ]
    default: present
'''

EXAMPLES = r'''
- name: Assign a logical network to a host network adapter
  microsoft.scvmm.scvmm_host_network_adapter:
    vm_host: "HVHost01"
    name: "Physical Adapter 1"
    logical_network: "Management"

- name: Assign an IP address pool to a host network adapter
  microsoft.scvmm.scvmm_host_network_adapter:
    vm_host: "HVHost01"
    name: "Physical Adapter 1"
    ip_address_pool: "Static IP Pool 1"
'''

RETURN = r'''
host_network_adapter:
  description: Properties of the host network adapter.
  returned: always
  type: dict
  contains:
    name:
      description: Name of the network adapter.
      type: str
    id:
      description: Identifier of the network adapter.
      type: str
    logical_networks:
      description: List of associated logical networks.
      type: list
      elements: str
    vm_host:
      description: Name of the host.
      type: str
'''
