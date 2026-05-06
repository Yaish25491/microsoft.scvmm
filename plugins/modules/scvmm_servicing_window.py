#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Project
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_servicing_window
short_description: Manage SCVMM servicing windows
description:
  - Manage System Center Virtual Machine Manager (SCVMM) servicing windows.
  - Create, update, and remove servicing windows.
  - This module wraps C(New-SCServicingWindow), C(Set-SCServicingWindow), and C(Remove-SCServicingWindow) cmdlets.
version_added: "1.0.0"
author:
  - Gemini (@gemini)
options:
  state:
    description:
      - The desired state of the servicing window.
    type: str
    choices: [ absent, present ]
    default: present
  name:
    description:
      - The name of the servicing window.
    type: str
    required: true
  description:
    description:
      - A description of the servicing window.
    type: str
  start_date:
    description:
      - The date the servicing window becomes active.
      - Use format "YYYY-MM-DD" or a format recognized by PowerShell's C(Get-Date).
    type: str
  start_time_of_day:
    description:
      - The time of day the servicing window starts.
      - Use format "HH:mm" (24-hour clock).
    type: str
  duration:
    description:
      - The duration of the servicing window.
    type: int
  duration_unit:
    description:
      - The unit for the duration.
    type: str
    choices: [ Hours, Minutes ]
    default: Hours
  time_zone:
    description:
      - The time zone index for the servicing window.
    type: int
  weekly_recurrence:
    description:
      - Specifies which days of the week the window repeats.
    type: list
    elements: str
    choices: [ Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday ]
  monthly_recurrence:
    description:
      - Specifies which day of the month the window repeats (1-31).
    type: int
  occurrence:
    description:
      - Used with monthly recurrence (e.g., 1st, 2nd, Last).
      - 1 for 1st, 2 for 2nd, 3 for 3rd, 4 for 4th, 5 for Last.
    type: int
'''

EXAMPLES = r'''
- name: Create a weekly servicing window
  microsoft.scvmm.scvmm_servicing_window:
    name: "Weekly Maintenance"
    description: "Standard Sunday maintenance"
    start_date: "2024-01-01"
    start_time_of_day: "02:00"
    duration: 4
    duration_unit: "Hours"
    weekly_recurrence:
      - Sunday

- name: Update a servicing window description
  microsoft.scvmm.scvmm_servicing_window:
    name: "Weekly Maintenance"
    description: "Updated maintenance description"

- name: Remove a servicing window
  microsoft.scvmm.scvmm_servicing_window:
    name: "Weekly Maintenance"
    state: absent
'''

RETURN = r'''
# No specific return values beyond standard 'changed' and module results.
'''
