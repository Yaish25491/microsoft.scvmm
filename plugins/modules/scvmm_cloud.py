#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_cloud
short_description: Manage SCVMM Private Clouds
description:
  - Manage SCVMM Private Clouds, including creation, update, and deletion.
  - Wraps New-SCCloud, Set-SCCloud, and Remove-SCCloud PowerShell cmdlets.
version_added: "1.0.0"
options:
  name:
    description:
      - Name of the private cloud.
    type: str
    required: true
  state:
    description:
      - Desired state of the private cloud.
    type: str
    choices: [ absent, present ]
    default: present
  host_group:
    description:
      - List of host group names or objects to associate with the cloud.
      - Required when I(state=present) and the cloud does not exist.
    type: list
    elements: str
  description:
    description:
      - Description of the private cloud.
    type: str
author:
  - Gemini CLI (@gemini)
'''

EXAMPLES = r'''
- name: Create a new private cloud
  microsoft.scvmm.scvmm_cloud:
    name: MyCloud
    state: present
    host_group:
      - "All Hosts"
    description: "My first private cloud"

- name: Update cloud description
  microsoft.scvmm.scvmm_cloud:
    name: MyCloud
    state: present
    description: "Updated description"

- name: Remove a private cloud
  microsoft.scvmm.scvmm_cloud:
    name: MyCloud
    state: absent
'''

RETURN = r'''
# Default return values
'''
