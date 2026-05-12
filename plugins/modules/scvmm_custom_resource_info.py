#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_custom_resource_info
short_description: Gather information about SCVMM custom resources
description:
  - Gather information about System Center Virtual Machine Manager (SCVMM) custom resources.
  - Wraps the C(Get-SCCustomResource) cmdlet.
options:
  name:
    description:
      - The name of the custom resource to retrieve info for.
    type: str
  id:
    description:
      - The unique identifier of the custom resource to retrieve info for.
    type: str
author:
  - Steve Fulmer (@stevefulmer)
'''

EXAMPLES = r'''
- name: Get info for all custom resources
  microsoft.scvmm.scvmm_custom_resource_info:

- name: Get info for a specific custom resource
  microsoft.scvmm.scvmm_custom_resource_info:
    name: "MyCustomResource.CR"
'''

RETURN = r'''
scvmm_custom_resources:
  description: A list of SCVMM custom resources matching the criteria.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: The name of the custom resource.
      type: str
      sample: "MyCustomResource.CR"
    id:
      description: The unique identifier of the custom resource.
      type: str
      sample: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
    description:
      description: The description of the custom resource.
      type: str
      sample: "A custom resource for web servers"
    family_name:
      description: The family name of the custom resource.
      type: str
      sample: "WebServerResources"
    release:
      description: The release version of the custom resource.
      type: str
      sample: "1.0.0"
    library_server:
      description: The name of the library server where the resource is stored.
      type: str
      sample: "vmm-library.contoso.com"
    share_path:
      description: The full UNC path to the custom resource folder on the library share.
      type: str
      sample: "\\\\vmm-library.contoso.com\\MSSCVMMLibrary\\MyCustomResource.CR"
    is_equivalent:
      description: Indicates if the resource is marked as equivalent to others.
      type: bool
      sample: false
    added_time:
      description: The timestamp when the resource was added to the library.
      type: str
      sample: "2026-05-01T12:00:00Z"
    modified_time:
      description: The timestamp when the resource was last modified.
      type: str
      sample: "2026-05-02T14:30:00Z"
'''
