#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function

__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_sql_profile
short_description: Manage SCVMM SQL Profiles
description:
  - Create, update, or remove System Center Virtual Machine Manager (SCVMM) SQL Profiles.
version_added: "1.0.0"
author:
  - Steve Fulmer (@stevefulmer)
options:
  name:
    description:
      - Name of the SQL Profile.
    type: str
    required: true
  description:
    description:
      - Description of the SQL Profile.
    type: str
  owner:
    description:
      - The owner of the SQL Profile.
    type: str
  user_role:
    description:
      - The user role associated with the SQL Profile.
    type: str
  state:
    description:
      - Assert the state of the SQL Profile.
      - If C(present), the profile will be created or updated.
      - If C(absent), the profile will be removed.
    type: str
    choices: [ absent, present ]
    default: present
'''

EXAMPLES = r'''
- name: Create a SQL Profile
  microsoft.scvmm.scvmm_sql_profile:
    name: "SQLProfile01"
    description: "Standard SQL Server Profile"
    state: present

- name: Update a SQL Profile
  microsoft.scvmm.scvmm_sql_profile:
    name: "SQLProfile01"
    description: "Updated description"
    state: present

- name: Remove a SQL Profile
  microsoft.scvmm.scvmm_sql_profile:
    name: "SQLProfile01"
    state: absent
'''

RETURN = r'''
sql_profile:
  description: A dictionary describing the SQL Profile.
  returned: success
  type: dict
  contains:
    name:
      description: The name of the SQL Profile.
      type: str
      sample: "SQLProfile01"
    id:
      description: The unique identifier of the SQL Profile.
      type: str
      sample: "00000000-0000-0000-0000-000000000000"
    description:
      description: The description of the SQL Profile.
      type: str
      sample: "Standard SQL Server Profile"
    owner:
      description: The owner of the SQL Profile.
      type: str
      sample: "DOMAIN\\User"
    user_role:
      description: The user role associated with the SQL Profile.
      type: str
      sample: "Administrator"
'''
