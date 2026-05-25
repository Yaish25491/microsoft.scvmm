#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_pxe_server_info
short_description: Gather information about SCVMM PXE servers
description:
  - Gathers information about PXE servers in System Center Virtual Machine Manager (SCVMM).
version_added: "1.0.0"
options:
  computer_name:
    description:
      - The Fully Qualified Domain Name (FQDN) or IP address of the PXE server to gather info about.
      - If not specified, information about all PXE servers is returned.
    type: str
author:
  - Steve Fulmer (@stevefulmer)
'''

EXAMPLES = r'''
- name: Gather info about all PXE servers
  microsoft.scvmm.scvmm_pxe_server_info:
  register: pxe_info

- name: Gather info about a specific PXE server
  microsoft.scvmm.scvmm_pxe_server_info:
    computer_name: pxe01.contoso.com
  register: pxe_info
'''

RETURN = r'''
pxe_servers:
  description: A list of PXE servers and their details.
  returned: always
  type: list
  elements: dict
  sample: [
    {
      "computer_name": "pxe01.contoso.com",
      "description": "Main PXE server",
      "id": "70966f98-4c92-426c-8438-662235948972",
      "is_connected": true,
      "version": "10.19.2505.0"
    }
  ]
'''
