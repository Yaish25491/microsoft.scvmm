#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_vm_subnet
short_description: Manage SCVMM VM Subnets
description:
  - Manage Virtual Machine Subnets in Microsoft System Center Virtual Machine Manager (SCVMM).
  - Can create, update, or remove VM Subnets.
author:
  - Steve Fulmer (@steve-fulmer)
options:
  name:
    description:
      - Name of the VM Subnet.
    type: str
    required: true
  vm_network:
    description:
      - Name of the VM Network to associate with the VM Subnet.
      - Required when I(state=present) and the VM Subnet does not exist.
    type: str
  description:
    description:
      - Description of the VM Subnet.
    type: str
  subnet_vlans:
    description:
      - A list of subnets and VLANs to associate with the VM Subnet.
      - Each element is a dict with C(subnet) and C(vlan) keys.
      - C(subnet) is the IP subnet in CIDR notation.
      - C(vlan) is the VLAN ID.
      - Required when creating a new VM Subnet.
    type: list
    elements: dict
    suboptions:
      subnet:
        description: IP subnet in CIDR notation.
        type: str
        required: true
      vlan:
        description: VLAN ID.
        type: int
  max_number_of_ports:
    description:
      - Maximum number of ports for the VM Subnet.
    type: int
  port_acl:
    description:
      - Name of the Port ACL to associate with the VM Subnet.
    type: str
  state:
    description:
      - Desired state of the VM Subnet.
    type: str
    choices: [ absent, present ]
    default: present
'''

EXAMPLES = r'''
- name: Create a VM Subnet
  microsoft.scvmm.scvmm_vm_subnet:
    name: MyVMSubnet
    vm_network: MyVMNetwork
    subnet_vlans:
      - subnet: 192.168.1.0/24
        vlan: 10
    state: present

- name: Update VM Subnet description
  microsoft.scvmm.scvmm_vm_subnet:
    name: MyVMSubnet
    description: Updated description
    state: present

- name: Remove a VM Subnet
  microsoft.scvmm.scvmm_vm_subnet:
    name: MyVMSubnet
    state: absent
'''

RETURN = r'''
vm_subnet:
  description: Properties of the VM Subnet.
  returned: when I(state=present)
  type: dict
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
          type: int
    max_number_of_ports:
      description: Maximum number of ports.
      type: int
    port_acl:
      description: Name of the Port ACL applied to the subnet.
      type: str
'''
