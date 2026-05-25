#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_script_info
short_description: Gather information about SCVMM Scripts
description:
  - Gather information about SCVMM Scripts.
  - Wraps Get-SCScript PowerShell cmdlet.
version_added: "1.0.0"
options:
  name:
    description:
      - Name of the script to gather information about.
      - If not specified, information for all scripts is returned.
    type: str
  vmm_server:
    description:
      - The VMM server to connect to.
    type: str
author:
  - Steve Fulmer (@steve-fulmer)
'''

EXAMPLES = r'''
- name: Gather information about all scripts
  microsoft.scvmm.scvmm_script_info:

- name: Gather information about a specific script
  microsoft.scvmm.scvmm_script_info:
    name: "Install-IIS.ps1"
'''

RETURN = r'''
scripts:
    description: List of scripts and their attributes.
    returned: always
    type: list
    elements: dict
    sample:
        - name: "Install-IIS.ps1"
          id: "12345678-1234-1234-1234-1234567890ab"
          description: "Script to install IIS"
          family_name: "Web Servers"
          release: "1.0"
          library_server: "libserver.domain.com"
          share_path: "\\\\libserver.domain.com\\Library\\Scripts"
          is_equivalent: true
          added_time: "2023-01-01T12:00:00Z"
          modified_time: "2023-01-01T12:00:00Z"
'''
