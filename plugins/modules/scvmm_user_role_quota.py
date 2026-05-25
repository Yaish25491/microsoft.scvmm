#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_user_role_quota
short_description: Manage SCVMM User Role Quotas
description:
  - Manage System Center Virtual Machine Manager (SCVMM) User Role Quotas.
  - Modifies the limits of an existing User Role Quota object for a given cloud and user role.
version_added: "1.0.0"
author:
  - Steve Fulmer (@steve-fulmer)
options:
  cloud:
    description:
      - The name of the SCVMM Private Cloud associated with the quota.
    type: str
    required: true
  user_role:
    description:
      - The name of the SCVMM User Role associated with the quota.
    type: str
    required: true
  quota_per_user:
    description:
      - Specifies whether the quota is applied per-user (true) or to the entire role (false).
    type: bool
    default: false
  cpu_count:
    description:
      - The maximum number of CPUs that can be allocated.
    type: int
  use_cpu_count_maximum:
    description:
      - If set to true, removes the CPU count limit.
    type: bool
  memory_mb:
    description:
      - The maximum amount of memory (in MB) that can be allocated.
    type: int
  use_memory_mb_maximum:
    description:
      - If set to true, removes the memory limit.
    type: bool
  storage_gb:
    description:
      - The maximum amount of storage (in GB) that can be allocated.
    type: int
  use_storage_gb_maximum:
    description:
      - If set to true, removes the storage limit.
    type: bool
  vm_count:
    description:
      - The maximum number of virtual machines that can be created.
    type: int
  use_vm_count_maximum:
    description:
      - If set to true, removes the virtual machine count limit.
    type: bool
  custom_quota_count:
    description:
      - The maximum custom quota count (points).
    type: int
  use_custom_quota_count_maximum:
    description:
      - If set to true, removes the custom quota count limit.
    type: bool
  use_maximum_quota:
    description:
      - Removes all limits (sets all quotas to maximum) if set to true.
    type: bool
  use_default:
    description:
      - Resets the quota to the default settings if set to true.
    type: bool
'''

EXAMPLES = r'''
- name: Update VM count and Memory limit for a user role quota
  microsoft.scvmm.scvmm_user_role_quota:
    cloud: "Cloud01"
    user_role: "SelfServiceUsers"
    quota_per_user: false
    vm_count: 50
    memory_mb: 204800
    use_cpu_count_maximum: true

- name: Set all quotas to unlimited
  microsoft.scvmm.scvmm_user_role_quota:
    cloud: "Cloud01"
    user_role: "SelfServiceUsers"
    use_maximum_quota: true
'''

RETURN = r'''
quota:
  description: A dictionary containing information about the modified SCVMM User Role Quota.
  returned: always
  type: dict
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
