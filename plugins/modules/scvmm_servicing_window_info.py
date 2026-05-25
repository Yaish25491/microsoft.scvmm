#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_servicing_window_info
short_description: Gather information about SCVMM servicing windows
description:
  - Gather information about System Center Virtual Machine Manager (SCVMM) servicing windows.
  - This module wraps the C(Get-SCServicingWindow) PowerShell cmdlet.
version_added: "1.0.0"
author:
  - Gemini (@gemini)
options:
  name:
    description:
      - The name of the servicing window to filter by.
    type: str
  id:
    description:
      - The unique identifier (GUID) of the servicing window to filter by.
    type: str
'''

EXAMPLES = r'''
- name: Gather information about all servicing windows
  microsoft.scvmm.scvmm_servicing_window_info:

- name: Gather information about a specific servicing window by name
  microsoft.scvmm.scvmm_servicing_window_info:
    name: "Weekly Maintenance"

- name: Gather information about a specific servicing window by ID
  microsoft.scvmm.scvmm_servicing_window_info:
    id: "12345678-1234-1234-1234-123456789012"
'''

RETURN = r'''
servicing_windows:
  description: A list of dictionaries containing information about the SCVMM servicing windows.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: The name of the servicing window.
      type: str
      sample: "Weekly Maintenance"
    id:
      description: The unique identifier (GUID) of the servicing window.
      type: str
      sample: "12345678-1234-1234-1234-123456789012"
    description:
      description: The description of the servicing window.
      type: str
      sample: "Standard weekly maintenance window"
    start_date:
      description: The date the servicing window starts.
      type: str
      sample: "2023-01-01T00:00:00"
    start_time_of_day:
      description: The time of day the servicing window starts.
      type: str
      sample: "2023-01-01T02:00:00"
    duration:
      description: The duration of the servicing window.
      type: int
      sample: 4
    duration_unit:
      description: The unit for the duration (e.g., Hours, Minutes).
      type: str
      sample: "Hours"
    time_zone:
      description: The time zone index for the servicing window.
      type: int
      sample: 35
    expiry_date:
      description: The date the servicing window expires.
      type: str
      sample: "2023-12-31T23:59:59"
'''
