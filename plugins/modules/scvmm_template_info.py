#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_template_info
short_description: Gather information about SCVMM VM templates
description:
  - Gather information about System Center Virtual Machine Manager (SCVMM) Virtual Machine templates.
  - Wraps the Get-SCVMTemplate cmdlet.
options:
  name:
    description:
      - The name of the virtual machine template to retrieve info for.
      - Supports wildcards.
    type: str
author:
  - Ansible Community (@ansible-community)
'''

EXAMPLES = r'''
- name: Get info for all VM templates
  microsoft.scvmm.scvmm_template_info:

- name: Get info for a specific VM template
  microsoft.scvmm.scvmm_template_info:
    name: "WindowsServer2022Template"

- name: Get info for all templates matching a pattern
  microsoft.scvmm.scvmm_template_info:
    name: "Windows*"
'''

RETURN = r'''
templates:
  description: A list of SCVMM Virtual Machine templates matching the criteria.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: The name of the template.
      type: str
      sample: "MyTemplate"
    id:
      description: The unique identifier of the template.
      type: str
      sample: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
    description:
      description: The description of the template.
      type: str
      sample: "Standard Windows Server 2022 Template"
    owner:
      description: The owner of the template.
      type: str
      sample: "CONTOSO\\Administrator"
    cpu_count:
      description: The number of CPUs assigned to the template.
      type: int
      sample: 2
    memory:
      description: The amount of memory assigned to the template in MB.
      type: int
      sample: 4096
    dynamic_memory_enabled:
      description: Whether dynamic memory is enabled for the template.
      type: bool
      sample: true
    operating_system:
      description: The operating system of the template.
      type: str
      sample: "64-bit edition of Windows Server 2022 Datacenter"
    is_highly_available:
      description: Whether VMs created from this template are highly available.
      type: bool
      sample: true
    library_server:
      description: The library server where the template is stored.
      type: str
      sample: "VMMServer01.contoso.com"
'''
