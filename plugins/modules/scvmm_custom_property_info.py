#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_custom_property_info
short_description: Gather information about SCVMM Custom Properties
description:
  - Gather information about SCVMM Custom Properties.
  - Wraps Get-SCCustomProperty PowerShell cmdlet.
version_added: "1.0.0"
options:
  name:
    description:
      - Name of the custom property to gather information about.
      - If not specified, information for all custom properties is returned.
    type: str
author:
  - Gemini CLI (@gemini)
'''

EXAMPLES = r'''
- name: Gather information about all custom properties
  microsoft.scvmm.scvmm_custom_property_info:

- name: Gather information about a specific custom property
  microsoft.scvmm.scvmm_custom_property_info:
    name: "Cost Center"
'''

RETURN = r'''
custom_properties:
    description: List of custom properties and their attributes.
    returned: always
    type: list
    elements: dict
    sample:
        - name: "Cost Center"
          id: "12345678-1234-1234-1234-1234567890ab"
          description: "Departmental billing code"
          members: ["VM", "VMHost"]
'''
