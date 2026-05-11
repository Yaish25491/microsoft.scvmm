#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_guest_os_profile_info
short_description: Gather information about SCVMM Guest OS Profiles
description:
  - Gathers information about System Center Virtual Machine Manager (SCVMM) Guest OS Profiles.
options:
  name:
    description:
      - The name of the guest OS profile to gather information about.
    type: str
author:
  - Steve Fulmer (@steve-fulmer)
'''

EXAMPLES = r'''
- name: Gather info about all guest OS profiles
  microsoft.scvmm.scvmm_guest_os_profile_info:

- name: Gather info about a specific guest OS profile
  microsoft.scvmm.scvmm_guest_os_profile_info:
    name: "MyGuestOSProfile"
'''

RETURN = r'''
guest_os_profiles:
  description: A list of guest OS profiles matching the criteria.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: The name of the profile.
      type: str
    id:
      description: The unique identifier of the profile.
      type: str
    description:
      description: The description of the profile.
      type: str
    operating_system:
      description: The operating system name.
      type: str
    computer_name:
      description: The computer name template.
      type: str
    full_name:
      description: The full name for registration.
      type: str
    organization_name:
      description: The organization name for registration.
      type: str
    product_key:
      description: The product key.
      type: str
    time_zone:
      description: The time zone index.
      type: int
    gui_run_once_commands:
      description: The GUI run once commands.
      type: list
      elements: str
    domain:
      description: The Active Directory domain.
      type: str
    domain_admin_credential:
      description: The Run As Account used to join the domain.
      type: str
    workgroup:
      description: The workgroup name.
      type: str
    answer_file:
      description: The answer file name.
      type: str
    linux_domain_name:
      description: The Linux domain name.
      type: str
    ssh_key:
      description: The SSH key name.
      type: str
    owner:
      description: The owner of the profile.
      type: str
    user_role:
      description: The user role associated with the profile.
      type: str
'''
