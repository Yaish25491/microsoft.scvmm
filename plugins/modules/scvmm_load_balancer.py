#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_load_balancer
short_description: Manage SCVMM Load Balancers
description:
  - Manage Load Balancers in Microsoft System Center Virtual Machine Manager (SCVMM).
  - Can add, update, and remove hardware load balancers.
author:
  - Steve Fulmer (@steve-fulmer)
options:
  name:
    description:
      - Name of the load balancer.
      - Used to identify the load balancer for updates and removal.
    type: str
    required: true
  state:
    description:
      - The desired state of the load balancer.
    type: str
    choices: [ absent, present ]
    default: present
  address:
    description:
      - The FQDN or IP address of the load balancer.
      - Required when I(state=present) and creating a new load balancer.
    type: str
  port:
    description:
      - The management port of the load balancer.
      - Required when I(state=present) and creating a new load balancer.
    type: int
  manufacturer:
    description:
      - The manufacturer of the load balancer.
      - Required when I(state=present) and creating a new load balancer.
    type: str
  model:
    description:
      - The model of the load balancer.
      - Required when I(state=present) and creating a new load balancer.
    type: str
  run_as_account:
    description:
      - The name of the SCVMM Run As Account used to connect to the load balancer.
      - Required when I(state=present) and creating a new load balancer.
    type: str
  description:
    description:
      - A description for the load balancer.
    type: str
  host_groups:
    description:
      - A list of VM Host Groups that are associated with this load balancer.
    type: list
    elements: str
  logical_network_vips:
    description:
      - A list of Logical Networks from which virtual IPs (VIPs) can be assigned.
    type: list
    elements: str
'''

EXAMPLES = r'''
- name: Add a new load balancer
  microsoft.scvmm.scvmm_load_balancer:
    name: LB01
    address: lb01.contoso.com
    port: 443
    manufacturer: Citrix
    model: NetScaler
    run_as_account: LBAdminAccount
    host_groups:
      - All Hosts
    logical_network_vips:
      - FrontendNetwork

- name: Update load balancer description
  microsoft.scvmm.scvmm_load_balancer:
    name: LB01
    description: Main Production Load Balancer

- name: Remove a load balancer
  microsoft.scvmm.scvmm_load_balancer:
    name: LB01
    state: absent
'''

RETURN = r'''
load_balancer:
  description: Properties of the load balancer.
  returned: always
  type: dict
  contains:
    name:
      description: Name of the load balancer.
      type: str
    id:
      description: Unique identifier of the load balancer.
      type: str
    address:
      description: Management address of the load balancer.
      type: str
    port:
      description: Management port.
      type: int
    manufacturer:
      description: Manufacturer name.
      type: str
    model:
      description: Model name.
      type: str
    description:
      description: Description of the load balancer.
      type: str
    host_groups:
      description: List of associated host groups.
      type: list
      elements: str
    logical_network_vips:
      description: List of associated logical network VIPs.
      type: list
      elements: str
'''
