#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_cloud_capacity
short_description: Manage SCVMM Cloud Capacity
description:
  - Manage the capacity limits of a private cloud in System Center Virtual Machine Manager (SCVMM).
  - Uses a JobGroup to apply capacity changes to the cloud.
options:
  name:
    description:
      - The name of the private cloud.
    type: str
    required: true
  cpu_count:
    description:
      - The maximum number of CPUs.
    type: int
  memory_mb:
    description:
      - The maximum memory in MB.
    type: int
  storage_gb:
    description:
      - The maximum storage in GB.
    type: int
  vm_count:
    description:
      - The maximum number of virtual machines.
    type: int
  vmm_server:
    description:
      - The name of the VMM server.
    type: str
author:
  - Steve Fulmer (@stevefulme1)
'''

EXAMPLES = r'''
- name: Set cloud capacity limits
  microsoft.scvmm.scvmm_cloud_capacity:
    name: "MyCloud"
    cpu_count: 50
    memory_mb: 102400
    vm_count: 20
'''

RETURN = r'''
capacity:
  description: The updated cloud capacity.
  returned: always
  type: dict
  sample:
    cpu_count: 50
    memory_mb: 102400
    storage_gb: 1000
    vm_count: 20
'''
