#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_port_classification
short_description: Manage SCVMM port classifications
description:
  - Create, update, or remove System Center Virtual Machine Manager (SCVMM) port classifications.
version_added: "1.0.0"
author:
  - Gemini (@gemini)
options:
  name:
    description:
      - The name of the port classification.
    type: str
    required: true
  description:
    description:
      - A description of the port classification.
    type: str
  state:
    description:
      - Whether the port classification should be present or absent.
    type: str
    choices: [ present, absent ]
    default: present
'''

EXAMPLES = r'''
- name: Create a new port classification
  microsoft.scvmm.scvmm_port_classification:
    name: High Bandwidth
    description: High bandwidth connection
    state: present

- name: Update the description of an existing port classification
  microsoft.scvmm.scvmm_port_classification:
    name: High Bandwidth
    description: Updated high bandwidth connection
    state: present

- name: Remove a port classification
  microsoft.scvmm.scvmm_port_classification:
    name: High Bandwidth
    state: absent
'''

RETURN = r'''
changed:
  description: Whether the port classification was changed.
  returned: always
  type: bool
  sample: true
port_classification:
  description: The port classification object.
  returned: when state is present
  type: dict
  contains:
    name:
      description: The name of the port classification.
      type: str
      sample: High Bandwidth
    id:
      description: The unique identifier (GUID) of the port classification.
      type: str
      sample: 12345678-1234-1234-1234-123456789012
    description:
      description: The description of the port classification.
      type: str
      sample: High bandwidth connection
'''
