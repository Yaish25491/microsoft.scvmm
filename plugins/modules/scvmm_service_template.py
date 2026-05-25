#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_service_template
short_description: Manage SCVMM service templates
description:
  - Create, update, or remove service templates in System Center Virtual Machine Manager (SCVMM).
author:
  - Steve Fulmer (@steve-fulmer)
options:
  state:
    description:
      - The desired state of the service template.
    type: str
    choices:
      - absent
      - present
    default: present
  name:
    description:
      - The name of the service template.
    type: str
    required: true
  new_name:
    description:
      - The new name of the service template when renaming an existing template.
    type: str
  release:
    description:
      - The release version of the service template (e.g., "1.0").
    type: str
    required: true
  description:
    description:
      - The description of the service template.
    type: str
  owner:
    description:
      - The owner of the service template.
    type: str
  service_priority:
    description:
      - The priority of the service template.
    type: str
    choices:
      - Low
      - Normal
      - High
  use_as_default_release:
    description:
      - Specifies whether to use this release as the default release.
    type: bool
  published:
    description:
      - Specifies whether the service template is published.
    type: bool
requirements:
  - VMMAdministration
'''

EXAMPLES = r'''
- name: Create a new service template
  microsoft.scvmm.scvmm_service_template:
    state: present
    name: "Web Application"
    release: "1.0"
    description: "Version 1.0 of the Web Application"
    service_priority: "Normal"

- name: Update an existing service template
  microsoft.scvmm.scvmm_service_template:
    state: present
    name: "Web Application"
    release: "1.0"
    service_priority: "High"
    published: true

- name: Rename a service template
  microsoft.scvmm.scvmm_service_template:
    state: present
    name: "Web Application"
    release: "1.0"
    new_name: "Web App Core"

- name: Remove a service template
  microsoft.scvmm.scvmm_service_template:
    state: absent
    name: "Web App Core"
    release: "1.0"
'''

RETURN = r'''
service_template:
  description: A dictionary containing information about the service template.
  returned: when state is present
  type: dict
  contains:
    name:
      description: The name of the service template.
      type: str
      sample: "Web Tier Template"
    id:
      description: The GUID of the service template.
      type: str
      sample: "b2a6a6a2-6b3a-4b9a-8f5f-1a1a1a1a1a1a"
    description:
      description: The description of the service template.
      type: str
      sample: "Standard Web Tier Service Template"
    release:
      description: The release version of the service template.
      type: str
      sample: "1.0"
    owner:
      description: The owner of the service template.
      type: str
      sample: "CONTOSO\\Admin"
    service_priority:
      description: The priority of the service template.
      type: str
      sample: "Normal"
    user_role:
      description: The user role associated with the service template.
      type: str
      sample: "Administrator"
    is_published:
      description: Whether the service template is published.
      type: bool
      sample: true
'''
