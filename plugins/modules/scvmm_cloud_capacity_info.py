#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_cloud_capacity_info
short_description: Gather capacity information for SCVMM Private Clouds
description:
  - Gather resource limit (quota) information for System Center Virtual Machine Manager (SCVMM) Private Clouds.
  - This module wraps the C(Get-SCCloudCapacity) PowerShell cmdlet.
version_added: "1.0.0"
author:
  - Gemini (@gemini)
options:
  cloud:
    description:
      - The name of the SCVMM Private Cloud to gather capacity for.
    type: str
    required: true
'''

EXAMPLES = r'''
- name: Gather capacity information for a specific Private Cloud
  microsoft.scvmm.scvmm_cloud_capacity_info:
    cloud: "Cloud01"
'''

RETURN = r'''
cloud_capacity:
  description: A dictionary containing capacity information for the SCVMM Private Cloud.
  returned: always
  type: dict
  contains:
    cpu_count:
      description: The maximum number of virtual CPUs allowed.
      type: int
      sample: 100
    memory_mb:
      description: The maximum amount of memory (in MB) allowed.
      type: int
      sample: 204800
    storage_gb:
      description: The maximum amount of storage (in GB) allowed.
      type: int
      sample: 1024
    vm_count:
      description: The maximum number of virtual machines allowed.
      type: int
      sample: 50
    custom_quota_points:
      description: The maximum number of custom quota points.
      type: int
      sample: 100
    use_maximum_cloud_capacity:
      description: Indicates if the cloud uses the maximum available capacity.
      type: bool
      sample: false
'''
