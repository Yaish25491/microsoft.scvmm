#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_user_role
short_description: Manage System Center Virtual Machine Manager (SCVMM) User Roles
description:
  - Create, update, and remove SCVMM user roles.
options:
  name:
    description:
      - The name of the user role.
    required: true
    type: str
  profile:
    description:
      - The user role profile. Required when creating a new user role.
      - Choices are Administrator, DelegatedAdmin, ReadOnlyAdmin, SelfServiceUser, TenantAdmin.
    type: str
    choices:
      - Administrator
      - DelegatedAdmin
      - ReadOnlyAdmin
      - SelfServiceUser
      - TenantAdmin
  description:
    description:
      - The description of the user role.
    type: str
  parent_user_role:
    description:
      - The parent user role name.
    type: str
  members:
    description:
      - A list of members to add to the user role.
      - Members not in this list will be removed if modifying an existing role.
    type: list
    elements: str
  state:
    description:
      - Whether the user role should be present or absent.
    type: str
    choices: [ absent, present ]
    default: present
author:
  - Steve Fulmer (@stevefulmer)
'''

EXAMPLES = r'''
- name: Create a user role
  microsoft.scvmm.scvmm_user_role:
    name: "MyRole"
    profile: "SelfServiceUser"
    description: "My Role"
    members:
      - "CONTOSO\\user1"
    state: present

- name: Remove a user role
  microsoft.scvmm.scvmm_user_role:
    name: "MyRole"
    state: absent
'''

RETURN = r'''
user_role:
  description: A dictionary containing the user role properties.
  returned: when state is present
  type: dict
  sample:
    name: "MyRole"
    id: "some-guid"
    description: "My Role"
    profile: "SelfServiceUser"
    members: ["CONTOSO\\user1"]
    parent_user_role: null
'''
