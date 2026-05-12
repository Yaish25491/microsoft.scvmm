#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_library_server_info
short_description: Gather information about SCVMM Library Servers
description:
  - Gathers information about System Center Virtual Machine Manager (SCVMM) Library Servers.
  - Wraps the Get-SCLibraryServer cmdlet.
version_added: "1.0.0"
author:
  - Steve Fulmer (@stevefulme1)
options:
  computer_name:
    description:
      - The computer name of the library server.
    type: str
  vmm_server:
    description:
      - The name of the VMM server to connect to.
    type: str
'''

EXAMPLES = r'''
- name: Gather information about all library servers
  microsoft.scvmm.scvmm_library_server_info:

- name: Gather information about a specific library server
  microsoft.scvmm.scvmm_library_server_info:
    computer_name: "libserver.contoso.com"
'''

RETURN = r'''
library_servers:
  description: A list of library servers.
  returned: always
  type: list
  elements: dict
'''
