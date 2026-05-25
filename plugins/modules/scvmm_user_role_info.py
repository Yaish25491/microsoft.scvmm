#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_user_role_info
short_description: Gather information about System Center Virtual Machine Manager (SCVMM) User Roles
description:
  - Gather information about SCVMM user roles.
options:
  name:
    description:
      - The name of the user role to get information about.
      - If not specified, returns information about all user roles.
    type: str
author:
  - Steve Fulmer (@stevefulmer)
'''

EXAMPLES = r'''
- name: Get info about a specific user role
  microsoft.scvmm.scvmm_user_role_info:
    name: "MyRole"

- name: Get info about all user roles
  microsoft.scvmm.scvmm_user_role_info:
'''

RETURN = r'''
user_roles:
  description: A list of dictionaries containing user role properties.
  returned: always
  type: list
  elements: dict
  sample:
    - name: "MyRole"
      id: "some-guid"
      description: "My Role"
      profile: "SelfServiceUser"
      members: ["CONTOSO\\user1"]
      parent_user_role: null
'''
