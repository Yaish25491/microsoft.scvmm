#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_iso_info
short_description: Gather information about SCVMM ISOs
description:
  - Gather information about SCVMM ISOs.
  - Wraps Get-SCISO PowerShell cmdlet.
version_added: "1.0.0"
options:
  name:
    description:
      - Name of the ISO to gather information about.
      - If not specified, information for all ISOs is returned.
    type: str
  vmm_server:
    description:
      - The VMM server to connect to.
    type: str
author:
  - Steve Fulmer (@steve-fulmer)
'''

EXAMPLES = r'''
- name: Gather information about all ISOs
  microsoft.scvmm.scvmm_iso_info:

- name: Gather information about a specific ISO
  microsoft.scvmm.scvmm_iso_info:
    name: "WindowsServer2022.iso"
'''

RETURN = r'''
isos:
    description: List of ISOs and their attributes.
    returned: always
    type: list
    elements: dict
    sample:
        - name: "WindowsServer2022.iso"
          id: "12345678-1234-1234-1234-1234567890ab"
          description: "Windows Server 2022 installation media"
          family_name: "Windows Server"
          release: "2022"
          library_server: "libserver.domain.com"
          share_path: "\\\\libserver.domain.com\\Library\\ISOs"
          size: 5368709120
          is_equivalent: true
          added_time: "2023-01-01T12:00:00Z"
          modified_time: "2023-01-01T12:00:00Z"
'''
