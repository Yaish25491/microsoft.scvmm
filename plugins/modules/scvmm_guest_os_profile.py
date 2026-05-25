#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_guest_os_profile
short_description: Manage SCVMM Guest OS Profiles
description:
  - Manages System Center Virtual Machine Manager (SCVMM) Guest OS Profiles.
options:
  name:
    description:
      - The name of the guest OS profile.
    type: str
    required: true
  state:
    description:
      - Whether the profile should be present or absent.
    type: str
    default: present
    choices:
      - present
      - absent
  description:
    description:
      - The description of the profile.
    type: str
  operating_system:
    description:
      - The name of the operating system (e.g., '64-bit edition of Windows Server 2022 Datacenter').
    type: str
  computer_name:
    description:
      - The computer name template. Can contain an asterisk (*) for random generation.
    type: str
  full_name:
    description:
      - The full name for Windows registration.
    type: str
  organization_name:
    description:
      - The organization name for Windows registration.
    type: str
  admin_password:
    description:
      - The local administrator password.
    type: str
  product_key:
    description:
      - The product key for Windows activation.
    type: str
  time_zone:
    description:
      - The time zone index (e.g., 4 for Pacific Time).
    type: int
  gui_run_once_commands:
    description:
      - A list of commands to run the first time a user logs on.
    type: list
    elements: str
  domain:
    description:
      - The Active Directory domain to join.
    type: str
  domain_admin_credential:
    description:
      - The name of the Run As Account used to join the domain.
    type: str
  workgroup:
    description:
      - The name of the workgroup to join.
    type: str
  answer_file:
    description:
      - The name of the answer file (Sysprep.inf or Unattend.xml) in the library.
    type: str
  linux_domain_name:
    description:
      - The DNS domain name for a Linux guest.
    type: str
  ssh_key:
    description:
      - The name of the SSH key in the library for a Linux guest.
    type: str
  owner:
    description:
      - The owner of the profile.
    type: str
  user_role:
    description:
      - The name of the user role associated with the profile.
    type: str
  vmm_server:
    description:
      - The VMM server to connect to.
    type: str
author:
  - Steve Fulmer (@steve-fulmer)
'''

EXAMPLES = r'''
- name: Create a basic Windows Guest OS Profile
  microsoft.scvmm.scvmm_guest_os_profile:
    name: "Win2022Profile"
    operating_system: "64-bit edition of Windows Server 2022 Datacenter"
    computer_name: "WS2022-*"
    admin_password: "MySecurePassword123!"

- name: Create a profile for domain join
  microsoft.scvmm.scvmm_guest_os_profile:
    name: "DomainProfile"
    operating_system: "64-bit edition of Windows Server 2022 Datacenter"
    domain: "contoso.com"
    domain_admin_credential: "DomainJoinAccount"

- name: Delete a profile
  microsoft.scvmm.scvmm_guest_os_profile:
    name: "Win2022Profile"
    state: absent
'''

RETURN = r'''
guest_os_profile:
  description: A dictionary containing the guest OS profile details.
  returned: when state is present
  type: dict
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
