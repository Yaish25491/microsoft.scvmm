#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_vm_nic
short_description: Manage SCVMM VM NICs
description:
  - Manage Virtual Network Adapters attached to a System Center Virtual Machine Manager (SCVMM) Virtual Machine.
  - Wraps the New-SCVirtualNetworkAdapter, Set-SCVirtualNetworkAdapter, and Remove-SCVirtualNetworkAdapter cmdlets.
options:
  vm_name:
    description:
      - The name of the virtual machine.
    type: str
    required: true
  name:
    description:
      - The name of the virtual network adapter to manage/update.
    type: str
  mac_address:
    description:
      - The MAC address for the adapter.
    type: str
  vm_network:
    description:
      - The name of the VM Network to connect to.
    type: str
  logical_network:
    description:
      - The name of the Logical Network to connect to.
    type: str
  state:
    description:
      - The desired state of the virtual network adapter.
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
- name: Add a virtual network adapter to a VM
  microsoft.scvmm.scvmm_vm_nic:
    vm_name: "MyVM"
    vm_network: "CorpNet"
    state: present
'''

RETURN = r'''
vm_nic:
  description: Information about the virtual network adapter.
  returned: always
  type: dict
'''
