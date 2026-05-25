#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_library_share
short_description: Manage SCVMM Library Shares
description:
  - Manage Library Shares in System Center Virtual Machine Manager (SCVMM).
  - Wraps Add-SCLibraryShare, Set-SCLibraryShare, and Remove-SCLibraryShare.
options:
  name:
    description:
      - The name of the library share.
    type: str
    required: true
  share_path:
    description:
      - The UNC path to the library share. Required when adding a new share.
    type: str
  description:
    description:
      - Description for the library share.
    type: str
  library_server:
    description:
      - The name of the library server that hosts the share. Required when adding.
    type: str
  state:
    description:
      - The desired state of the library share.
    type: str
    choices: [absent, present]
    default: present
  vmm_server:
    description:
      - The name of the VMM server.
    type: str
author:
  - Steve Fulmer (@stevefulme1)
'''

EXAMPLES = r'''
- name: Add a library share
  microsoft.scvmm.scvmm_library_share:
    name: "VMMShare"
    share_path: "\\\\libserver.contoso.com\\VMMShare"
    library_server: "libserver.contoso.com"
    state: present
'''

RETURN = r'''
library_share:
  description: Information about the library share.
  returned: always
  type: dict
'''
