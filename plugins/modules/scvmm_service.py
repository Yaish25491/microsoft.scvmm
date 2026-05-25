#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_service
short_description: Manage SCVMM services
description:
    - Manage services in System Center Virtual Machine Manager (SCVMM).
    - Supports creating, updating, removing, starting, and stopping services.
options:
    name:
        description:
            - The name of the service.
        required: true
        type: str
    state:
        description:
            - The desired state of the service.
            - C(present) ensures the service exists.
            - C(absent) ensures the service is removed.
            - C(started) ensures the service exists and is running.
            - C(stopped) ensures the service exists and is stopped.
        choices: ['present', 'absent', 'started', 'stopped']
        default: present
        type: str
    service_configuration:
        description:
            - The name of the Service Configuration to use when deploying a new service.
            - Required when creating a new service.
        type: str
    description:
        description:
            - The description of the service.
        type: str
    owner:
        description:
            - The owner of the service.
        type: str
    user_role:
        description:
            - The user role associated with the service.
        type: str
    cost_center:
        description:
            - The cost center for the service.
        type: str
    release:
        description:
            - The release string of the service.
        type: str
author:
    - Steve Fulmer (@stevefulmer)
'''

EXAMPLES = r'''
- name: Deploy a new service
  microsoft.scvmm.scvmm_service:
    name: "MyService"
    service_configuration: "MyServiceConfig"
    state: present

- name: Update an existing service
  microsoft.scvmm.scvmm_service:
    name: "MyService"
    description: "Updated description"
    state: present

- name: Start a service
  microsoft.scvmm.scvmm_service:
    name: "MyService"
    state: started

- name: Stop a service
  microsoft.scvmm.scvmm_service:
    name: "MyService"
    state: stopped

- name: Remove a service
  microsoft.scvmm.scvmm_service:
    name: "MyService"
    state: absent
'''

RETURN = r'''
service:
    description: A dictionary describing the service.
    returned: when state is not absent
    type: dict
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
'''
