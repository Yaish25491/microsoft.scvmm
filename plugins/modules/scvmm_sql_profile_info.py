#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function

__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_sql_profile_info
short_description: Get information about a SCVMM SQL Profile
description:
  - Gets information about a System Center Virtual Machine Manager (SCVMM) SQL Profile.
version_added: "1.0.0"
author:
  - Steve Fulmer (@stevefulmer)
options:
  name:
    description:
      - Name of the SQL Profile.
      - If not specified, all SQL Profiles are returned.
    type: str
'''

EXAMPLES = r'''
- name: Get info about all SQL Profiles
  microsoft.scvmm.scvmm_sql_profile_info:

- name: Get info about a specific SQL Profile
  microsoft.scvmm.scvmm_sql_profile_info:
    name: "SQLProfile01"
'''

RETURN = r'''
sql_profiles:
  description: A list of dictionaries describing the SQL Profiles.
  returned: always
  type: list
  elements: dict
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
