#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_run_as_account
short_description: Manage SCVMM Run As Accounts
description:
  - Manages Run As Accounts in System Center Virtual Machine Manager (SCVMM).
author:
  - Steve Fulmer (@sfulmer)
options:
  name:
    description:
      - The name of the Run As Account.
    type: str
    required: true
  state:
    description:
      - Specifies whether the Run As Account should exist or not.
    type: str
    choices: [ absent, present ]
    default: present
  description:
    description:
      - The description of the Run As Account.
    type: str
  user_name:
    description:
      - The username for the Run As Account. Usually in domain\username format.
      - Required when creating a new Run As Account.
    type: str
  password:
    description:
      - The password for the Run As Account.
      - Required when creating a new Run As Account.
    type: str
  no_validation:
    description:
      - Specifies whether VMM should validate the credentials against Active Directory during creation.
    type: bool
    default: false
'''

EXAMPLES = r'''
- name: Create a new Run As Account
  microsoft.scvmm.scvmm_run_as_account:
    name: "AdminAccount"
    user_name: "DOMAIN\\admin"
    password: "SuperSecretPassword123!"
    description: "Domain Admin for VMM"
    state: present

- name: Update the description and password of an existing Run As Account
  microsoft.scvmm.scvmm_run_as_account:
    name: "AdminAccount"
    description: "Updated description"
    user_name: "DOMAIN\\admin"
    password: "NewPassword123!"

- name: Remove a Run As Account
  microsoft.scvmm.scvmm_run_as_account:
    name: "AdminAccount"
    state: absent
'''

RETURN = r'''
run_as_account:
  description: Information about the Run As Account.
  returned: when state is present
  type: dict
  contains:
    name:
      description: The name of the Run As Account.
      type: str
    id:
      description: The unique identifier (GUID) of the Run As Account.
      type: str
    description:
      description: The description of the Run As Account.
      type: str
    user_name:
      description: The username associated with the Run As Account.
      type: str
    is_enabled:
      description: Indicates if the account is enabled.
      type: bool
    owner:
      description: The owner of the Run As Account.
      type: str
'''
