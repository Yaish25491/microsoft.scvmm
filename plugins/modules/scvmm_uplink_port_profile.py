#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_uplink_port_profile
short_description: Manage SCVMM uplink port profiles
description:
  - Manage System Center Virtual Machine Manager (SCVMM) uplink port profiles, including creating, updating, and removing them.
  - This module handles Native Uplink Port Profiles.
version_added: "1.0.0"
author:
  - Gemini (@gemini)
options:
  name:
    description:
      - The name of the uplink port profile.
    type: str
    required: true
  description:
    description:
      - A description for the uplink port profile.
    type: str
  lbfo_load_balancing_algorithm:
    description:
      - Specifies the load-balancing algorithm.
    type: str
    choices: [HyperVPort, TransportPorts, IPAddresses, MACAddresses, Dynamic]
  lbfo_teaming_mode:
    description:
      - Specifies the teaming mode.
    type: str
    choices: [SwitchIndependent, LACP, Static]
  enable_network_virtualization:
    description:
      - Indicates whether to enable Hyper-V Network Virtualization.
    type: bool
  logical_network_definitions:
    description:
      - A list of logical network definitions (network sites) to associate with this profile.
    type: list
    elements: str
  state:
    description:
      - The desired state of the uplink port profile.
    type: str
    choices: [absent, present]
    default: present
'''

EXAMPLES = r'''
- name: Create an uplink port profile
  microsoft.scvmm.scvmm_uplink_port_profile:
    name: "UplinkProfile01"
    lbfo_load_balancing_algorithm: "Dynamic"
    lbfo_teaming_mode: "SwitchIndependent"
    logical_network_definitions:
      - "LogicalNetwork01_Site01"

- name: Update description and add a logical network definition
  microsoft.scvmm.scvmm_uplink_port_profile:
    name: "UplinkProfile01"
    description: "Updated description"
    logical_network_definitions:
      - "LogicalNetwork01_Site01"
      - "LogicalNetwork01_Site02"

- name: Remove an uplink port profile
  microsoft.scvmm.scvmm_uplink_port_profile:
    name: "UplinkProfile01"
    state: absent
'''

RETURN = r'''
uplink_port_profile:
  description: A dictionary containing information about the SCVMM uplink port profile.
  returned: on success and state is present
  type: dict
  contains:
    name:
      description: The name of the uplink port profile.
      type: str
    id:
      description: The unique identifier (GUID) of the uplink port profile.
      type: str
    description:
      description: The description of the uplink port profile.
      type: str
    lbfo_load_balancing_algorithm:
      description: The load balancing algorithm.
      type: str
    lbfo_teaming_mode:
      description: The teaming mode.
      type: str
    enable_network_virtualization:
      description: Whether network virtualization is enabled.
      type: bool
    logical_network_definitions:
      description: A list of associated logical network definitions.
      type: list
      elements: str
'''
