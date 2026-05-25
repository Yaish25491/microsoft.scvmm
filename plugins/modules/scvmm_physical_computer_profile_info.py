#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_physical_computer_profile_info
short_description: Gather information about SCVMM physical computer profiles
description:
  - Gather information about System Center Virtual Machine Manager (SCVMM) physical computer profiles.
  - Wraps the Get-SCPhysicalComputerProfile cmdlet.
options:
  name:
    description:
      - The name of the physical computer profile to retrieve info for.
      - Supports wildcards.
    type: str
author:
  - Ansible Community (@ansible-community)
'''

EXAMPLES = r'''
- name: Get info for all physical computer profiles
  microsoft.scvmm.scvmm_physical_computer_profile_info:

- name: Get info for a specific physical computer profile
  microsoft.scvmm.scvmm_physical_computer_profile_info:
    name: "MyPhysicalProfile"
'''

RETURN = r'''
physical_computer_profiles:
  description: A list of SCVMM physical computer profiles matching the criteria.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: The name of the profile.
      type: str
      sample: "MyProfile"
    id:
      description: The unique identifier of the profile.
      type: str
      sample: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
    description:
      description: The description of the profile.
      type: str
      sample: "Standard Hyper-V Host Profile"
    owner:
      description: The owner of the profile.
      type: str
      sample: "CONTOSO\\Administrator"
    virtual_hard_disk:
      description: The name of the virtual hard disk used as the OS image.
      type: str
      sample: "WindowsServer2022.vhdx"
    domain:
      description: The FQDN of the domain to join.
      type: str
      sample: "contoso.com"
    join_workgroup:
      description: Whether the computer joins a workgroup.
      type: bool
      sample: false
    use_as_vm_host:
      description: Whether the computer is configured as a Hyper-V host.
      type: bool
      sample: true
    use_as_file_server:
      description: Whether the computer is configured as a file server.
      type: bool
      sample: false
    time_zone:
      description: The time zone index for the OS.
      type: int
      sample: 35
    product_key:
      description: The Windows product key.
      type: str
      sample: "XXXXX-XXXXX-XXXXX-XXXXX-XXXXX"
    answer_file:
      description: The name of the answer file associated with the profile.
      type: str
      sample: "unattend.xml"
    gui_run_once_commands:
      description: Commands to run the first time a user logs on.
      type: list
      elements: str
      sample: ["powershell.exe -Command Write-Host 'Hello'"]
    driver_matching_tags:
      description: Tags used to match drivers during deployment.
      type: list
      elements: str
      sample: ["HP", "Proliant"]
    disk_configuration:
      description: Disk partitioning requirements.
      type: str
      sample: "1-Primary-300MB,2-Primary-Remaining-True"
    is_guarded:
      description: Indicates if the host should be deployed as a guarded host.
      type: bool
      sample: false
'''
