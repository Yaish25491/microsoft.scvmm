#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_vm_network
short_description: Manage SCVMM VM Networks
description:
  - Manage Virtual Machine Networks in Microsoft System Center Virtual Machine Manager (SCVMM).
  - Can create, update, or remove VM Networks.
author:
  - Steve Fulmer (@steve-fulmer)
options:
  name:
    description:
      - Name of the VM Network.
    type: str
    required: true
  logical_network:
    description:
      - Name of the logical network to associate with the VM Network.
      - Required when I(state=present) and the VM Network does not exist.
    type: str
  description:
    description:
      - Description of the VM Network.
    type: str
  isolation_type:
    description:
      - The isolation type of the VM Network.
    type: str
    choices: [ NoIsolation, Isolated ]
  state:
    description:
      - Desired state of the VM Network.
    type: str
    choices: [ absent, present ]
    default: present
'''

EXAMPLES = r'''
- name: Create a VM Network
  microsoft.scvmm.scvmm_vm_network:
    name: MyVMNetwork
    logical_network: MyLogicalNetwork
    state: present

- name: Update VM Network description
  microsoft.scvmm.scvmm_vm_network:
    name: MyVMNetwork
    description: Updated description
    state: present

- name: Remove a VM Network
  microsoft.scvmm.scvmm_vm_network:
    name: MyVMNetwork
    state: absent
'''

RETURN = r'''
vm_network:
  description: Properties of the VM Network.
  returned: when I(state=present)
  type: dict
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
'''
