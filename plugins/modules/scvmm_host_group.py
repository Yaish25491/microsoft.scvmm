#!/usr/bin/python
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_host_group
short_description: Manage SCVMM Host Groups
description:
  - Manage Host Groups in System Center Virtual Machine Manager (SCVMM).
  - Can create, update, and remove Host Groups.
author:
  - Jarvis OS (@jarvis)
options:
  name:
    description:
      - The name of the host group.
    type: str
    required: true
  parent_group:
    description:
      - The name or path of the parent host group.
      - If not specified, the host group will be created under the "All Hosts" root group.
    type: str
  description:
    description:
      - A description for the host group.
    type: str
  state:
    description:
      - The desired state of the host group.
    type: str
    choices: [ absent, present ]
    default: present
'''

EXAMPLES = r'''
- name: Create a new host group
  microsoft.scvmm.scvmm_host_group:
    name: "Production"
    parent_group: "All Hosts"
    description: "Production Host Group"
    state: present

- name: Update an existing host group
  microsoft.scvmm.scvmm_host_group:
    name: "Production"
    description: "Updated Production Host Group"
    state: present

- name: Remove a host group
  microsoft.scvmm.scvmm_host_group:
    name: "Production"
    state: absent
'''

RETURN = r'''
host_group:
  description: The properties of the managed host group.
  returned: success and state is present
  type: dict
  sample:
    name: "Production"
    id: "6f9619ff-8b86-d011-b42d-00c04fc964ff"
    path: "All Hosts\Production"
    description: "Production Host Group"
    parent_host_group: "All Hosts"
'''
