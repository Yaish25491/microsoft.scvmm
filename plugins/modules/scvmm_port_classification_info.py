#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_port_classification_info
short_description: Gather information about SCVMM Port Classifications
description:
  - Gather information about System Center Virtual Machine Manager (SCVMM) Port Classifications.
  - This module wraps the C(Get-SCPortClassification) PowerShell cmdlet.
version_added: "1.0.0"
author:
  - Gemini (@gemini)
options:
  name:
    description:
      - The name of the SCVMM Port Classification to filter by.
    type: str
'''

EXAMPLES = r'''
- name: Gather information about all Port Classifications
  microsoft.scvmm.scvmm_port_classification_info:

- name: Gather information about a specific Port Classification by name
  microsoft.scvmm.scvmm_port_classification_info:
    name: "High Bandwidth"
'''

RETURN = r'''
port_classifications:
  description: A list of dictionaries containing information about the SCVMM Port Classifications.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: The name of the port classification.
      type: str
      sample: "High Bandwidth"
    id:
      description: The unique identifier (GUID) of the port classification.
      type: str
      sample: "12345678-1234-1234-1234-123456789012"
    description:
      description: The description of the port classification.
      type: str
      sample: "High bandwidth port classification for web servers."
'''
