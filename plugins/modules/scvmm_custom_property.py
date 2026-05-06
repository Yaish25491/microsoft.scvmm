#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2025, Gemini CLI
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_custom_property
short_description: Manage SCVMM Custom Properties
description:
  - Manage SCVMM Custom Properties, including creation, update, and deletion.
  - Wraps New-SCCustomProperty, Set-SCCustomProperty, and Remove-SCCustomProperty PowerShell cmdlets.
version_added: "1.0.0"
options:
  name:
    description:
      - Name of the custom property.
    type: str
    required: true
  state:
    description:
      - Desired state of the custom property.
    type: str
    choices: [ absent, present ]
    default: present
  description:
    description:
      - Description of the custom property.
    type: str
  add_member:
    description:
      - List of member types to add to the custom property.
      - Valid members include C(VM), C(VMHost), C(Cloud), C(ServiceTemplate), etc.
    type: list
    elements: str
  remove_member:
    description:
      - List of member types to remove from the custom property.
    type: list
    elements: str
author:
  - Gemini CLI (@gemini)
'''

EXAMPLES = r'''
- name: Create a new custom property for VMs and Hosts
  microsoft.scvmm.scvmm_custom_property:
    name: "Cost Center"
    add_member:
      - VM
      - VMHost
    description: "Departmental billing code"

- name: Update custom property description
  microsoft.scvmm.scvmm_custom_property:
    name: "Cost Center"
    description: "Updated billing code description"

- name: Remove a custom property
  microsoft.scvmm.scvmm_custom_property:
    name: "Cost Center"
    state: absent
'''

RETURN = r'''
# Default return values
'''
