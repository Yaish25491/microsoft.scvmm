#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_application_profile
short_description: Manage SCVMM application profiles
description:
  - Manage System Center Virtual Machine Manager (SCVMM) Application Profiles.
  - Wraps the C(New-SCApplicationProfile), C(Set-SCApplicationProfile), and C(Remove-SCApplicationProfile) cmdlets.
options:
  name:
    description:
      - The name of the application profile.
    type: str
    required: true
  description:
    description:
      - The description of the application profile.
    type: str
  compatibility_v3:
    description:
      - Specifies whether the application profile is compatible with VMM 2012.
      - Only applicable when creating a new application profile.
    type: bool
  owner:
    description:
      - The owner of the application profile.
    type: str
  user_role:
    description:
      - The user role of the application profile.
    type: str
  state:
    description:
      - Whether the application profile should be present or absent.
    type: str
    choices:
      - present
      - absent
    default: present
author:
  - Ansible Community (@ansible-community)
'''

EXAMPLES = r'''
- name: Create an application profile
  microsoft.scvmm.scvmm_application_profile:
    name: "WebAppProfile"
    description: "Standard Web App Profile"
    state: present

- name: Update an application profile
  microsoft.scvmm.scvmm_application_profile:
    name: "WebAppProfile"
    description: "Updated Web App Profile"
    state: present

- name: Remove an application profile
  microsoft.scvmm.scvmm_application_profile:
    name: "WebAppProfile"
    state: absent
'''

RETURN = r'''
application_profile:
  description: Information about the application profile.
  returned: when state is present
  type: dict
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
