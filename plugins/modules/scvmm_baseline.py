#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Gemini CLI
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_baseline
short_description: Manage SCVMM update baselines
description:
  - Manage SCVMM update baselines, including creation, update, and deletion.
  - Wraps New-SCBaseline, Set-SCBaseline, and Remove-SCBaseline PowerShell cmdlets.
version_added: "1.0.0"
options:
  name:
    description:
      - Name of the baseline.
    type: str
    required: true
  state:
    description:
      - Desired state of the baseline.
    type: str
    choices: [ absent, present ]
    default: present
  description:
    description:
      - Description of the baseline.
    type: str
  updates:
    description:
      - List of update names or IDs to include in the baseline.
    type: list
    elements: str
  assignment_scope:
    description:
      - List of objects (Host Groups, Host Clusters, or Managed Computers) to assign the baseline to.
      - Can be names or IDs.
    type: list
    elements: str
author:
  - Gemini CLI (@gemini)
'''

EXAMPLES = r'''
- name: Create a new baseline
  microsoft.scvmm.scvmm_baseline:
    name: "Security Baseline"
    state: present
    description: "Critical security updates"
    updates:
      - "Security Update for Windows Server 2022 (KB5012345)"
    assignment_scope:
      - "All Hosts"

- name: Update baseline updates
  microsoft.scvmm.scvmm_baseline:
    name: "Security Baseline"
    state: present
    updates:
      - "Security Update for Windows Server 2022 (KB5012345)"
      - "Security Update for Windows Server 2022 (KB5067890)"

- name: Remove a baseline
  microsoft.scvmm.scvmm_baseline:
    name: "Security Baseline"
    state: absent
'''

RETURN = r'''
baseline:
  description: The updated or created baseline object.
  returned: always
  type: dict
  contains:
    name:
      description: Name of the baseline.
      type: str
    id:
      description: GUID of the baseline.
      type: str
'''
