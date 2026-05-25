#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_logical_switch
short_description: Manage SCVMM Logical Switches
description:
  - Manages Logical Switches in System Center Virtual Machine Manager (SCVMM).
author:
  - Steve Fulmer (@stevefulmer)
options:
  name:
    description:
      - Name of the logical switch.
    type: str
    required: true
  state:
    description:
      - Desired state of the logical switch.
    type: str
    choices: [ absent, present ]
    default: present
  description:
    description:
      - Description of the logical switch.
    type: str
  enable_sriov:
    description:
      - Whether to enable SR-IOV.
    type: bool
  switch_uplink_mode:
    description:
      - The uplink mode.
    type: str
    choices: [ NoTeam, Team, EmbeddedTeam ]
  minimum_bandwidth_mode:
    description:
      - The bandwidth management mode.
    type: str
    choices: [ Default, Weight, Absolute, None ]
  enable_packet_direct:
    description:
      - Whether to enable Packet Direct.
    type: bool
'''

EXAMPLES = r'''
- name: Create a logical switch
  microsoft.scvmm.scvmm_logical_switch:
    name: MyLogicalSwitch
    description: "Production Logical Switch"
    switch_uplink_mode: Team
    minimum_bandwidth_mode: Weight
    state: present

- name: Delete a logical switch
  microsoft.scvmm.scvmm_logical_switch:
    name: MyLogicalSwitch
    state: absent
'''

RETURN = r'''
scvmm_logical_switch:
  description: The logical switch object.
  returned: always
  type: dict
  contains:
    name:
      description: Name of the logical switch.
      type: str
    id:
      description: GUID of the logical switch.
      type: str
'''
