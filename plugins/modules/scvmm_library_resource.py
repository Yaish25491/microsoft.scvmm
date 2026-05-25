#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_library_resource
short_description: Manage SCVMM Library Resources
description:
  - Manage SCVMM Library Resources such as ISOs or scripts.
  - Can be used to set properties or remove the resource.
version_added: "1.0.0"
author:
  - Steve Fulmer (@stevefulme1)
options:
  name:
    description:
      - Name of the library resource.
    type: str
    required: true
  state:
    description:
      - State of the library resource.
    type: str
    default: present
    choices: [absent, present]
  description:
    description:
      - Description of the library resource.
    type: str
  library_server:
    description:
      - The library server where the resource is located.
    type: str
'''

EXAMPLES = r'''
- name: Update description of a library resource
  microsoft.scvmm.scvmm_library_resource:
    name: "MyScript.ps1"
    description: "Updated script"
    state: present

- name: Remove a library resource
  microsoft.scvmm.scvmm_library_resource:
    name: "OldISO.iso"
    state: absent
'''

RETURN = r'''
library_resource:
  description: A dictionary containing information about the library resource.
  returned: always
  type: dict
  contains:
    name:
      description: Name of the library resource.
      type: str
    id:
      description: The GUID of the library resource.
      type: str
    description:
      description: Description of the library resource.
      type: str
    library_server:
      description: The library server name.
      type: str
    share_path:
      description: The share path of the resource.
      type: str
'''
