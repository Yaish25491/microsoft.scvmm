#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_uplink_port_profile_info
short_description: Gather information about SCVMM Uplink Port Profiles
description:
  - Gather information about System Center Virtual Machine Manager (SCVMM) Uplink Port Profiles.
  - This module wraps the C(Get-SCUplinkPortProfile) PowerShell cmdlet.
version_added: "1.0.0"
author:
  - Gemini (@gemini)
options:
  name:
    description:
      - The name of the SCVMM Uplink Port Profile to filter by.
    type: str
'''

EXAMPLES = r'''
- name: Gather information about all Uplink Port Profiles
  microsoft.scvmm.scvmm_uplink_port_profile_info:

- name: Gather information about a specific Uplink Port Profile by name
  microsoft.scvmm.scvmm_uplink_port_profile_info:
    name: "UplinkProfile01"
'''

RETURN = r'''
uplink_port_profiles:
  description: A list of dictionaries containing information about the SCVMM Uplink Port Profiles.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: The name of the uplink port profile.
      type: str
      sample: "UplinkProfile01"
    id:
      description: The unique identifier (GUID) of the uplink port profile.
      type: str
      sample: "12345678-1234-1234-1234-123456789012"
    description:
      description: The description of the uplink port profile.
      type: str
      sample: "Uplink port profile for management network."
    lbfo_load_balancing_algorithm:
      description: The load balancing algorithm for the profile.
      type: str
      sample: "Dynamic"
    lbfo_teaming_mode:
      description: The teaming mode for the profile.
      type: str
      sample: "SwitchIndependent"
    enable_network_virtualization:
      description: Whether network virtualization is enabled.
      type: bool
      sample: true
    logical_network_definitions:
      description: A list of logical network definitions associated with the profile.
      type: list
      elements: str
      sample: ["LogicalNetwork01"]
'''
