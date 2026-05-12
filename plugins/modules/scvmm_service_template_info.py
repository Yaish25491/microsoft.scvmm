#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_service_template_info
short_description: Gather information about SCVMM service templates
description:
  - Gathers information about one or more service templates in System Center Virtual Machine Manager (SCVMM).
author:
  - Steve Fulmer (@steve-fulmer)
options:
  name:
    description:
      - The name of the service template.
    type: str
  release:
    description:
      - The release version of the service template.
    type: str
requirements:
  - VMMAdministration
'''

EXAMPLES = r'''
- name: Gather info for all service templates
  microsoft.scvmm.scvmm_service_template_info:

- name: Gather info for a specific service template by name
  microsoft.scvmm.scvmm_service_template_info:
    name: "Web Tier Template"

- name: Gather info for a specific service template by name and release
  microsoft.scvmm.scvmm_service_template_info:
    name: "Web Tier Template"
    release: "1.0"
'''

RETURN = r'''
service_templates:
  description: A list of dictionaries containing information about the service templates.
  returned: always
  type: list
  elements: dict
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
