#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_compliance_scan
short_description: Initiate a compliance scan on SCVMM objects
description:
  - Initiates a compliance scan of a managed computer or an update server against baselines.
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
      - Target the VMM Server itself for compliance scan.
    type: bool
    default: no
  vm_host:
    description:
      - The name of the VM host to scan.
    type: str
  host_cluster:
    description:
      - The name of the VM host cluster to scan.
    type: str
  vm:
    description:
      - The name of the virtual machine to scan.
    type: str
  force_scan:
    description:
      - If C(true), a scan will always be triggered, and the module will return C(changed=true).
      - If C(false) (the default), the module will check the current compliance status.
      - If it is already C(Compliant) or C(NotCompliant), the scan will be skipped to maintain idempotency.
    type: bool
    default: no
  baseline_name:
    description:
      - Scan against a specific baseline. If omitted, the object is scanned against all assigned baselines.
    type: str
'''

EXAMPLES = r'''
- name: Initiate a compliance scan on a VM host if not already scanned
  microsoft.scvmm.scvmm_compliance_scan:
    vm_host: "Host01.contoso.com"

- name: Force a compliance scan on the VMM server
  microsoft.scvmm.scvmm_compliance_scan:
    vmm_server_object: true
    force_scan: true
'''

RETURN = r'''
compliance_status:
  description: A list of dictionaries describing the compliance status after the scan.
  returned: always
  type: list
  elements: dict
  contains:
    compliance_status:
      description: The compliance status.
      type: str
    last_scan_time:
      description: The time of the last compliance scan.
      type: str
    object_name:
      description: The name of the object.
      type: str
    object_type:
      description: The type of the object.
      type: str
    baseline_name:
      description: The name of the baseline evaluated.
      type: str
'''
