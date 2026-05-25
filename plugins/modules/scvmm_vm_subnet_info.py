#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_vm_subnet_info
short_description: Gather information about SCVMM VM Subnets
description:
  - Gather information about Virtual Machine Subnets in Microsoft System Center Virtual Machine Manager (SCVMM).
author:
  - Steve Fulmer (@steve-fulmer)
options:
  name:
    description:
      - Name of the VM Subnet to gather information about.
      - If not specified, all VM Subnets will be returned.
    type: str
  vm_network:
    description:
      - Name of the VM Network to filter subnets.
    type: str
'''

EXAMPLES = r'''
- name: Gather information about all VM Subnets
  microsoft.scvmm.scvmm_vm_subnet_info:

- name: Gather information about a specific VM Subnet
  microsoft.scvmm.scvmm_vm_subnet_info:
    name: MyVMSubnet
'''

RETURN = r'''
vm_subnets:
  description: A list of VM Subnets and their properties.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: Name of the VM Subnet.
      type: str
    id:
      description: Identifier of the VM Subnet.
      type: str
    description:
      description: Description of the VM Subnet.
      type: str
    vm_network:
      description: Name of the parent VM Network.
      type: str
    subnet_vlans:
      description: List of subnet/VLAN associations.
      type: list
      elements: dict
      contains:
        subnet:
          description: IP subnet in CIDR notation.
          type: str
        vlan:
          description: VLAN ID.
          type: str
    max_number_of_ports:
      description: Maximum number of ports.
      type: int
    port_acl:
      description: Name of the Port ACL applied to the subnet.
      type: str
'''
