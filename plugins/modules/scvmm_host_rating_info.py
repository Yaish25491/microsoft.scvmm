#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_host_rating_info
short_description: Gather placement ratings for hosts
description:
  - Gather placement ratings for one or more hosts to determine their suitability for a specific virtual machine.
  - This module wraps the C(Get-SCVMHostRating) PowerShell cmdlet.
version_added: "1.0.0"
author:
  - Gemini (@gemini)
options:
  vm:
    description:
      - The name of an existing virtual machine to use for the rating calculation.
      - Exactly one of I(vm), I(vm_template), or hardware requirements (I(cpu_count), I(memory_mb), I(disk_space_gb)) must be provided.
    type: str
  vm_template:
    description:
      - The name of a virtual machine template to use for the rating calculation.
    type: str
  vm_host:
    description:
      - The name of a single host to be rated.
      - If neither I(vm_host) nor I(vm_host_group) is provided, all hosts are rated.
    type: str
  vm_host_group:
    description:
      - The name of a host group to be rated.
    type: str
  cpu_count:
    description:
      - The number of CPUs required for the rating calculation.
    type: int
  memory_mb:
    description:
      - The amount of memory (in MB) required for the rating calculation.
    type: int
  disk_space_gb:
    description:
      - The amount of disk space (in GB) required for the rating calculation.
    type: int
  placement_goal:
    description:
      - The optimization goal for the rating.
    type: str
    choices: [ LoadBalance, ResourceMaximization ]
'''

EXAMPLES = r'''
- name: Rate a specific host for an existing VM
  microsoft.scvmm.scvmm_host_rating_info:
    vm: "VM01"
    vm_host: "Host01.contoso.com"

- name: Rate all hosts in a group for a new VM based on a template
  microsoft.scvmm.scvmm_host_rating_info:
    vm_template: "Win2022Template"
    vm_host_group: "Production"

- name: Rate a host based on custom hardware requirements
  microsoft.scvmm.scvmm_host_rating_info:
    vm_host: "Host02.contoso.com"
    cpu_count: 2
    memory_mb: 4096
    disk_space_gb: 100
'''

RETURN = r'''
host_ratings:
  description: A list of dictionaries containing host ratings.
  returned: always
  type: list
  elements: dict
  contains:
    vm_host:
      description: The name of the host being rated.
      type: str
      sample: "Host01.contoso.com"
    rating:
      description: An integer (0 to 5) indicating the overall suitability of the host.
      type: int
      sample: 5
    explanation:
      description: A detailed explanation why a host received a specific rating.
      type: str
      sample: "The host has sufficient resources."
    is_eligible:
      description: Indicates if the host meets the minimum requirements to host the VM.
      type: bool
      sample: true
'''
