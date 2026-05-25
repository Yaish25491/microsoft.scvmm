#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_compliance_info
short_description: Gather compliance status information from SCVMM
description:
  - Gathers the compliance status of a VMM object.
version_added: '2.0.0'
author:
  - Steve Fulmer (@SteveFulmer)
options:
  vmm_server:
    description:
      - The name of the VMM server.
    type: str
  vmm_server_object:
    description:
      - Target the VMM Server itself for compliance information.
    type: bool
    default: no
  vm_host:
    description:
      - The name of the VM host.
    type: str
  host_cluster:
    description:
      - The name of the VM host cluster.
    type: str
  vm:
    description:
      - The name of the virtual machine.
    type: str
  baseline_name:
    description:
      - Filter compliance status by a specific baseline name.
    type: str
'''

EXAMPLES = r'''
- name: Get compliance info for a VM host
  microsoft.scvmm.scvmm_compliance_info:
    vm_host: "Host01.contoso.com"

- name: Get compliance info for the VMM server
  microsoft.scvmm.scvmm_compliance_info:
    vmm_server_object: true

- name: Get compliance info for a VM
  microsoft.scvmm.scvmm_compliance_info:
    vm: "WebVM01"
'''

RETURN = r'''
compliance_status:
  description: A list of dictionaries describing the compliance status.
  returned: always
  type: list
  elements: dict
  contains:
    compliance_status:
      description: The compliance status (e.g., Compliant, NotCompliant, Unknown).
      type: str
      sample: "Compliant"
    last_scan_time:
      description: The time of the last compliance scan.
      type: str
      sample: "2026-05-24T10:00:00Z"
    object_name:
      description: The name of the object.
      type: str
      sample: "Host01.contoso.com"
    object_type:
      description: The type of the object.
      type: str
      sample: "VMHost"
    baseline_name:
      description: The name of the baseline evaluated.
      type: str
      sample: "Security Baseline 1.0"
    error_code:
      description: Error code if compliance check failed.
      type: str
    error_description:
      description: Error description if compliance check failed.
      type: str
'''
