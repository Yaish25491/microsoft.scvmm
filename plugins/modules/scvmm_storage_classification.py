#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_storage_classification
short_description: Manage SCVMM storage classifications
description:
  - Create, update, or remove System Center Virtual Machine Manager (SCVMM) storage classifications.
version_added: "1.0.0"
author:
  - Gemini (@gemini)
options:
  name:
    description:
      - The name of the storage classification.
    type: str
    required: true
  description:
    description:
      - A description of the storage classification.
    type: str
  state:
    description:
      - Whether the storage classification should be present or absent.
    type: str
    choices: [ present, absent ]
    default: present
'''

EXAMPLES = r'''
- name: Create a new storage classification
  microsoft.scvmm.scvmm_storage_classification:
    name: Gold
    description: High performance solid state storage
    state: present

- name: Update the description of an existing storage classification
  microsoft.scvmm.scvmm_storage_classification:
    name: Gold
    description: Updated high performance solid state storage
    state: present

- name: Remove a storage classification
  microsoft.scvmm.scvmm_storage_classification:
    name: Gold
    state: absent
'''

RETURN = r'''
changed:
  description: Whether the storage classification was changed.
  returned: always
  type: bool
  sample: true
storage_classification:
  description: The storage classification object.
  returned: when state is present
  type: dict
  contains:
    name:
      description: The name of the storage classification.
      type: str
      sample: Gold
    id:
      description: The unique identifier (GUID) of the storage classification.
      type: str
      sample: 12345678-1234-1234-1234-123456789012
    description:
      description: The description of the storage classification.
      type: str
      sample: High performance storage
    is_read_only:
      description: Whether the storage classification is read-only.
      type: bool
      sample: false
    is_system:
      description: Whether the storage classification is a system classification.
      type: bool
      sample: false
'''
