#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_capability_profile
short_description: Manage SCVMM Capability Profiles
description:
  - Manage Capability Profiles in System Center Virtual Machine Manager (SCVMM).
options:
  name:
    description:
      - The name of the capability profile.
    required: true
    type: str
  state:
    description:
      - The desired state of the capability profile.
    choices: [ absent, present ]
    default: present
    type: str
  description:
    description:
      - The description of the capability profile.
    type: str
  capability_type:
    description:
      - The type of capability profile. Required when creating a new profile.
    type: str
author:
  - Steve Fulmer (@stevefulmer)
'''

EXAMPLES = r'''
- name: Create a capability profile
  microsoft.scvmm.scvmm_capability_profile:
    name: "TestCapabilityProfile"
    capability_type: "HyperV"
    description: "A test capability profile"

- name: Update a capability profile
  microsoft.scvmm.scvmm_capability_profile:
    name: "TestCapabilityProfile"
    description: "Updated description"

- name: Remove a capability profile
  microsoft.scvmm.scvmm_capability_profile:
    name: "TestCapabilityProfile"
    state: absent
'''

RETURN = r'''
capability_profile:
  description: A dictionary containing information about the capability profile.
  returned: when state is present
  type: dict
  sample: {
    "name": "TestCapabilityProfile",
    "description": "A test capability profile",
    "capability_type": "HyperV"
  }
'''
