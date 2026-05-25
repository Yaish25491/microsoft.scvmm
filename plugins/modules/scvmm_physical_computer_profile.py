#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_physical_computer_profile
short_description: Manage SCVMM Physical Computer Profiles
description:
  - Manage the lifecycle of Physical Computer Profiles in System Center Virtual Machine Manager (SCVMM).
  - Used for bare metal provisioning of Hyper-V hosts.
options:
  name:
    description:
      - The name of the physical computer profile.
    type: str
    required: true
  description:
    description:
      - The description of the profile.
    type: str
  state:
    description:
      - The desired state of the profile.
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
- name: Create a physical computer profile
  microsoft.scvmm.scvmm_physical_computer_profile:
    name: "StandardHostProfile"
    description: "Profile for standard bare metal Hyper-V hosts"
    state: present
'''

RETURN = r'''
physical_computer_profile:
  description: Information about the profile.
  returned: always
  type: dict
'''
