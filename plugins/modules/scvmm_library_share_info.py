#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Ansible Project
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_library_share_info
short_description: Gather information about SCVMM Library Shares
description:
  - Gather information about SCVMM Library Shares.
version_added: "1.0.0"
author:
  - Steve Fulmer (@stevefulme1)
options:
  name:
    description:
      - Name of the library share to retrieve information for.
    type: str
  library_server:
    description:
      - The name of the library server to filter shares by.
    type: str


'''

EXAMPLES = r'''
- name: Gather information about all library shares
  microsoft.scvmm.scvmm_library_share_info:

- name: Gather information about a specific library share
  microsoft.scvmm.scvmm_library_share_info:
    name: "MSSCVMMLibrary"

- name: Gather information about library shares on a specific server
  microsoft.scvmm.scvmm_library_share_info:
    library_server: "VMMServer.contoso.com"
'''

RETURN = r'''
library_shares:
  description: A list of dictionaries containing information about the library shares.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: Name of the library share.
      type: str
      sample: "MSSCVMMLibrary"
    id:
      description: The GUID of the library share.
      type: str
      sample: "12345678-1234-1234-1234-123456789012"
    description:
      description: Description of the library share.
      type: str
      sample: "Default library share"
    path:
      description: The path to the library share.
      type: str
      sample: "\\\\VMMServer.contoso.com\\MSSCVMMLibrary"
    library_server:
      description: The library server name.
      type: str
      sample: "VMMServer.contoso.com"
    is_read_only:
      description: Indicates if the share is read-only.
      type: bool
      sample: false
'''
