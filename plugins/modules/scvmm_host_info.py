#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2024, Ansible Project
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_host_info
short_description: Gather information about SCVMM VM Hosts
description:
    - Gather information about System Center Virtual Machine Manager (SCVMM) VM Hosts.
    - Supports filtering by host name or host group.
version_added: "1.0.0"
author:
    - Gemini CLI (@gemini)
options:
    name:
        description:
            - The name of the host to gather information about.
        type: str
    host_group:
        description:
            - The name of the host group to filter hosts by.
        type: str
requirements:
    - VirtualMachineManager PowerShell module
'''

EXAMPLES = r'''
- name: Gather info about all SCVMM hosts
  microsoft.scvmm.scvmm_host_info:

- name: Gather info about a specific SCVMM host by name
  microsoft.scvmm.scvmm_host_info:
    name: "HVHost01"

- name: Gather info about all hosts in a specific host group
  microsoft.scvmm.scvmm_host_info:
    host_group: "All Hosts\Production"
'''

RETURN = r'''
hosts:
    description: A list of SCVMM hosts.
    returned: always
    type: list
    elements: dict
    contains:
        name:
            description: The name of the host.
            returned: always
            type: str
            sample: "HVHost01"
        id:
            description: The unique identifier for the host.
            returned: always
            type: str
            sample: "56303030-3131-3131-3131-313131313131"
        description:
            description: The description of the host.
            returned: always
            type: str
            sample: "Production Hyper-V Host"
        host_group:
            description: The name of the host group the host belongs to.
            returned: always
            type: str
            sample: "All Hosts\Production"
        virtualization_platform:
            description: The virtualization platform used by the host.
            returned: always
            type: str
            sample: "HyperV"
        operating_system:
            description: The operating system of the host.
            returned: always
            type: str
            sample: "Microsoft Windows Server 2022 Datacenter"
        overall_state:
            description: The overall health state of the host.
            returned: always
            type: str
            sample: "OK"
        total_memory:
            description: The total memory of the host in bytes.
            returned: always
            type: int
            sample: 34359738368
        available_memory:
            description: The available memory of the host in bytes.
            returned: always
            type: int
            sample: 17179869184
        cpu_count:
            description: The number of CPUs on the host.
            returned: always
            type: int
            sample: 8
        cpu_utilization:
            description: The CPU utilization of the host as a percentage.
            returned: always
            type: int
            sample: 15
        is_connected:
            description: Whether the host is currently connected to SCVMM.
            returned: always
            type: bool
            sample: true
'''
