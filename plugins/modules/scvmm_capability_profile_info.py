#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_capability_profile_info
short_description: Gather information about SCVMM Capability Profiles
description:
  - Gathers information about System Center Virtual Machine Manager (SCVMM) Capability Profiles.
version_added: "1.0.0"
author:
  - Steve Fulmer (@stevefulme1)
options:
  name:
    description:
      - The name of the capability profile.
    type: str
'''

EXAMPLES = r'''
- name: Gather information about all capability profiles
  microsoft.scvmm.scvmm_capability_profile_info:

- name: Gather information about a specific capability profile
  microsoft.scvmm.scvmm_capability_profile_info:
    name: "HyperV"
'''

RETURN = r'''
capability_profiles:
  description: A list of capability profiles.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: The name of the capability profile.
      type: str
      sample: "HyperV"
    id:
      description: The unique identifier.
      type: str
      sample: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
    description:
      description: The description of the capability profile.
      type: str
      sample: "Hyper-V Capability Profile"
'''
