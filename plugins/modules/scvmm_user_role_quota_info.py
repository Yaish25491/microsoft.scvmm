#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_user_role_quota_info
short_description: Gather information about SCVMM User Role Quotas
description:
  - Gather information about System Center Virtual Machine Manager (SCVMM) User Role Quotas.
  - This module wraps the C(Get-SCUserRoleQuota) PowerShell cmdlet.
version_added: "1.0.0"
author:
  - Steve Fulmer (@steve-fulmer)
options:
  cloud:
    description:
      - The name of the SCVMM Private Cloud to filter by.
    type: str
  user_role:
    description:
      - The name of the SCVMM User Role to filter by.
    type: str
  quota_per_user:
    description:
      - Indicates whether to get the member-level quota (true) or role-level quota (false).
    type: bool
'''

EXAMPLES = r'''
- name: Gather information about all User Role Quotas
  microsoft.scvmm.scvmm_user_role_quota_info:

- name: Gather role-level quota for a specific user role and cloud
  microsoft.scvmm.scvmm_user_role_quota_info:
    cloud: "Cloud01"
    user_role: "SelfServiceUsers"
    quota_per_user: false
'''

RETURN = r'''
quotas:
  description: A list of dictionaries containing information about the SCVMM User Role Quotas.
  returned: always
  type: list
  elements: dict
  contains:
    id:
      description: The unique identifier (GUID) of the user role quota.
      type: str
      sample: "12345678-1234-1234-1234-123456789012"
    cloud:
      description: The name of the private cloud.
      type: str
      sample: "Cloud01"
    user_role:
      description: The name of the user role.
      type: str
      sample: "SelfServiceUsers"
    quota_per_user:
      description: Indicates if this is a per-user quota.
      type: bool
      sample: false
    cpu_count:
      description: The CPU count limit.
      type: int
      sample: 10
    use_cpu_count_maximum:
      description: Indicates whether the CPU count is set to maximum (unlimited).
      type: bool
      sample: false
    memory_mb:
      description: The memory limit in MB.
      type: int
      sample: 10240
    use_memory_mb_maximum:
      description: Indicates whether the memory limit is set to maximum (unlimited).
      type: bool
      sample: false
    storage_gb:
      description: The storage limit in GB.
      type: int
      sample: 100
    use_storage_gb_maximum:
      description: Indicates whether the storage limit is set to maximum (unlimited).
      type: bool
      sample: false
    vm_count:
      description: The virtual machine count limit.
      type: int
      sample: 5
    use_vm_count_maximum:
      description: Indicates whether the virtual machine count limit is set to maximum (unlimited).
      type: bool
      sample: false
    custom_quota_count:
      description: The custom quota count limit.
      type: int
      sample: 0
    use_custom_quota_count_maximum:
      description: Indicates whether the custom quota count limit is set to maximum (unlimited).
      type: bool
      sample: true
'''
