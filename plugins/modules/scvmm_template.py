#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_template
short_description: Manage SCVMM VM Templates
description:
  - Manage the lifecycle of System Center Virtual Machine Manager (SCVMM) VM Templates.
  - Wraps the New-SCVMTemplate, Set-SCVMTemplate, Remove-SCVMTemplate, and Get-SCVMTemplate cmdlets.
options:
  name:
    description:
      - The name of the VM template.
    type: str
    required: true
  state:
    description:
      - The desired state of the VM template.
    type: str
    choices: [absent, present]
    default: present
  description:
    description:
      - The description of the VM template.
    type: str
  owner:
    description:
      - The owner of the VM template.
    type: str
  vmm_server:
    description:
      - The name of the VMM server to connect to.
    type: str
author:
  - Steve Fulmer (@stevefulme1)
'''

EXAMPLES = r'''
- name: Create or update a VM template
  microsoft.scvmm.scvmm_template:
    name: "Win2022-Standard"
    state: present
    description: "Standard Windows Server 2022 Template"
    owner: "CONTOSO\\Admin"

- name: Remove a VM template
  microsoft.scvmm.scvmm_template:
    name: "Old-Template"
    state: absent
'''

RETURN = r'''
template:
  description: Information about the VM template.
  returned: always
  type: dict
  contains:
    name:
      description: The name of the VM template.
      type: str
      sample: "Win2022-Standard"
    id:
      description: The unique identifier of the VM template.
      type: str
      sample: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
    description:
      description: The description of the VM template.
      type: str
      sample: "Standard Windows Server 2022 Template"
    owner:
      description: The owner of the VM template.
      type: str
      sample: "CONTOSO\\Admin"
'''
