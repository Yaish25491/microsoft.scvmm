#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_run_as_account_info
short_description: Gather information about SCVMM Run As Accounts
description:
  - Gathers information about one or more Run As Accounts in System Center Virtual Machine Manager (SCVMM).
author:
  - Steve Fulmer (@sfulmer)
options:
  name:
    description:
      - The name of the Run As Account.
    type: str
'''

EXAMPLES = r'''
- name: Get information about all Run As Accounts
  microsoft.scvmm.scvmm_run_as_account_info:

- name: Get information about a specific Run As Account
  microsoft.scvmm.scvmm_run_as_account_info:
    name: "AdminAccount"
'''

RETURN = r'''
run_as_accounts:
  description: A list of Run As Accounts.
  returned: always
  type: list
  elements: dict
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
