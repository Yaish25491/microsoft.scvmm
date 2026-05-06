#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Gemini CLI
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_baseline_info
short_description: Gather information about SCVMM update baselines
description:
  - Gather information about SCVMM update baselines.
version_added: "1.0.0"
options:
  name:
    description:
      - Name of the baseline to gather information for.
      - If not specified, all baselines will be returned.
    type: str
author:
  - Gemini CLI (@gemini)
'''

EXAMPLES = r'''
- name: Get all baselines
  microsoft.scvmm.scvmm_baseline_info:

- name: Get a specific baseline by name
  microsoft.scvmm.scvmm_baseline_info:
    name: "Security Baseline"
'''

RETURN = r'''
baselines:
  description: List of SCVMM update baselines.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: Name of the baseline.
      returned: always
      type: str
      sample: "Security Baseline"
    id:
      description: GUID of the baseline.
      returned: always
      type: str
      sample: "567e8901-2345-6789-0123-456789012345"
    description:
      description: Description of the baseline.
      returned: always
      type: str
      sample: "Critical security updates"
    updates:
      description: List of updates in the baseline.
      returned: always
      type: list
      elements: dict
      contains:
        name:
          description: Name of the update.
          type: str
        id:
          description: GUID of the update.
          type: str
        bulletin_id:
          description: Bulletin ID of the update.
          type: str
    assignment_scope:
      description: List of objects in the assignment scope.
      returned: always
      type: list
      elements: dict
      contains:
        name:
          description: Name of the scope object.
          type: str
        id:
          description: GUID of the scope object.
          type: str
        type:
          description: Type of the scope object.
          type: str
'''
