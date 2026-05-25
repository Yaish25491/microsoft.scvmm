#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_application_profile_info
short_description: Gather information about SCVMM application profiles
description:
  - Gather information about System Center Virtual Machine Manager (SCVMM) Application Profiles.
  - Wraps the C(Get-SCApplicationProfile) cmdlet.
options:
  name:
    description:
      - The name of the application profile to retrieve info for.
      - Supports wildcards.
    type: str
author:
  - Ansible Community (@ansible-community)
'''

EXAMPLES = r'''
- name: Get info for all application profiles
  microsoft.scvmm.scvmm_application_profile_info:

- name: Get info for a specific application profile
  microsoft.scvmm.scvmm_application_profile_info:
    name: "Web App Profile"

- name: Get info for all profiles matching a pattern
  microsoft.scvmm.scvmm_application_profile_info:
    name: "Web*"
'''

RETURN = r'''
application_profiles:
  description: A list of SCVMM application profiles matching the criteria.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: The name of the application profile.
      type: str
      sample: "WebAppProfile"
    id:
      description: The unique identifier of the application profile.
      type: str
      sample: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
    description:
      description: The description of the application profile.
      type: str
      sample: "Standard Web App Profile"
    owner:
      description: The owner of the application profile.
      type: str
      sample: "CONTOSO\\Administrator"
    compatibility_v3:
      description: Indicates whether the application profile is compatible with VMM 2012.
      type: bool
      sample: true
'''
