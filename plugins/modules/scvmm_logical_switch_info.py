#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_logical_switch_info
short_description: Gather information about SCVMM Logical Switches
description:
  - Gathers information about Logical Switches in System Center Virtual Machine Manager (SCVMM).
author:
  - Steve Fulmer (@stevefulmer)
options:
  name:
    description:
      - Name of the logical switch to gather information for.
      - If not provided, all logical switches will be returned.
    type: str
'''

EXAMPLES = r'''
- name: Gather info about all logical switches
  microsoft.scvmm.scvmm_logical_switch_info:

- name: Gather info about a specific logical switch by name
  microsoft.scvmm.scvmm_logical_switch_info:
    name: MyLogicalSwitch
'''

RETURN = r'''
scvmm_logical_switches:
  description: List of logical switches found.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: Name of the logical switch.
      returned: always
      type: str
      sample: MyLogicalSwitch
    id:
      description: GUID of the logical switch.
      returned: always
      type: str
      sample: 12345678-1234-1234-1234-1234567890ab
    description:
      description: Description of the logical switch.
      returned: always
      type: str
      sample: Core Logical Switch
    enable_sriov:
      description: Whether SR-IOV is enabled.
      returned: always
      type: bool
      sample: false
    switch_uplink_mode:
      description: The uplink mode (NoTeam, Team, EmbeddedTeam).
      returned: always
      type: str
      sample: Team
    minimum_bandwidth_mode:
      description: The bandwidth management mode (Default, Weight, Absolute, None).
      returned: always
      type: str
      sample: Weight
    enable_packet_direct:
      description: Whether Packet Direct is enabled.
      returned: always
      type: bool
      sample: false
    virtual_switch_extensions:
      description: List of virtual switch extensions.
      returned: always
      type: list
      elements: dict
      contains:
        name:
          description: Name of the extension.
          type: str
        id:
          description: GUID of the extension.
          type: str
        description:
          description: Description of the extension.
          type: str
        vendor:
          description: Vendor of the extension.
          type: str
        version:
          description: Version of the extension.
          type: str
        extension_type:
          description: Type of the extension.
          type: str
'''
