#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_hardware_profile
short_description: Manage SCVMM Hardware Profiles
description:
  - Manage the lifecycle of System Center Virtual Machine Manager (SCVMM) Hardware Profiles.
  - Wraps the New-SCHardwareProfile, Set-SCHardwareProfile, Remove-SCHardwareProfile cmdlets.
options:
  name:
    description:
      - The name of the Hardware Profile.
    type: str
    required: true
  state:
    description:
      - The desired state of the Hardware Profile.
    type: str
    choices: [absent, present]
    default: present
  description:
    description:
      - The description of the Hardware Profile.
    type: str
  owner:
    description:
      - The owner of the Hardware Profile.
    type: str
  memory_mb:
    description:
      - The amount of memory assigned to the VMs created from this profile, in MB.
    type: int
  cpu_count:
    description:
      - The number of virtual CPUs for VMs created from this profile.
    type: int
  cpu_type:
    description:
      - The specific CPU type (e.g. "3.60 GHz Xeon (2 MB L2 cache)").
    type: str
  highly_available:
    description:
      - Specifies whether VMs created from this hardware profile should be highly available.
    type: bool
  dynamic_memory_enabled:
    description:
      - Specifies whether dynamic memory is enabled.
    type: bool
  dynamic_memory_minimum_mb:
    description:
      - The minimum amount of memory, in MB, assigned when dynamic memory is enabled.
    type: int
  dynamic_memory_maximum_mb:
    description:
      - The maximum amount of memory, in MB, assigned when dynamic memory is enabled.
    type: int
  dynamic_memory_buffer_percentage:
    description:
      - The dynamic memory buffer percentage.
    type: int
  vmm_server:
    description:
      - The name of the VMM server to connect to.
    type: str
author:
  - Steve Fulmer (@stevefulme1)
'''

EXAMPLES = r'''
- name: Create or update a Hardware Profile
  microsoft.scvmm.scvmm_hardware_profile:
    name: "WebSrv-Profile"
    state: present
    description: "Hardware Profile for Web Servers"
    memory_mb: 2048
    cpu_count: 2
    highly_available: true

- name: Remove a Hardware Profile
  microsoft.scvmm.scvmm_hardware_profile:
    name: "Old-Profile"
    state: absent
'''

RETURN = r'''
hardware_profile:
  description: Information about the hardware profile.
  returned: always
  type: dict
  contains:
    name:
      description: The name of the Hardware Profile.
      type: str
      sample: "WebSrv-Profile"
    id:
      description: The unique identifier of the Hardware Profile.
      type: str
      sample: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
    description:
      description: The description of the Hardware Profile.
      type: str
    owner:
      description: The owner of the Hardware Profile.
      type: str
    memory_mb:
      description: The amount of memory assigned (in MB).
      type: int
    cpu_count:
      description: The number of virtual CPUs.
      type: int
    cpu_type:
      description: The CPU type.
      type: str
    highly_available:
      description: Indicates if VMs created from this profile are highly available.
      type: bool
    boot_order:
      description: The boot order of the hardware profile.
      type: list
      elements: str
    dynamic_memory_enabled:
      description: Indicates if dynamic memory is enabled.
      type: bool
    dynamic_memory_minimum_mb:
      description: The minimum amount of memory assigned when dynamic memory is enabled.
      type: int
    dynamic_memory_maximum_mb:
      description: The maximum amount of memory assigned when dynamic memory is enabled.
      type: int
    dynamic_memory_buffer_percentage:
      description: The dynamic memory buffer percentage.
      type: int
    cpu_relative_weight:
      description: The relative weight for the CPU.
      type: int
    cpu_reserve:
      description: The CPU reserve percentage.
      type: int
    cpu_maximum_percent:
      description: The maximum CPU percentage.
      type: int
    limit_cpu_functionality:
      description: Indicates if CPU functionality is limited for compatibility.
      type: bool
    limit_cpu_for_migration:
      description: Indicates if CPU features are limited to allow migration.
      type: bool
'''
