#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_service_info
short_description: Gather information about SCVMM services
description:
    - Gather information about services in System Center Virtual Machine Manager (SCVMM).
options:
    name:
        description:
            - The name of the service to gather information for.
        type: str
author:
    - Steve Fulmer (@stevefulmer)
'''

EXAMPLES = r'''
- name: Gather info for a specific service
  microsoft.scvmm.scvmm_service_info:
    name: "MyService"

- name: Gather info for all services
  microsoft.scvmm.scvmm_service_info:
'''

RETURN = r'''
services:
    description: A list of dictionaries describing the services.
    returned: always
    type: list
    elements: dict
    contains:
        name:
            description: The name of the service.
            type: str
            sample: "MyService"
        id:
            description: The unique ID of the service.
            type: str
            sample: "b845d0ed-689b-43d9-93e1-2cba4a88f5f6"
        description:
            description: The description of the service.
            type: str
        status:
            description: The status of the service.
            type: str
            sample: "OK"
        service_template:
            description: The name of the service template used.
            type: str
            sample: "Template1"
        user_role:
            description: The user role associated with the service.
            type: str
            sample: "Administrator"
        owner:
            description: The owner of the service.
            type: str
            sample: "DOMAIN\\User"
        release:
            description: The release string of the service.
            type: str
        cost_center:
            description: The cost center associated with the service.
            type: str
        is_recoverable:
            description: Whether the service is recoverable.
            type: bool
            sample: true
'''
