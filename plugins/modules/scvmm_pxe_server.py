#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_pxe_server
short_description: Manage SCVMM PXE servers
description:
  - Adds or removes a PXE server in System Center Virtual Machine Manager (SCVMM).
  - The PXE server must have the Windows Deployment Services (WDS) role installed and configured.
version_added: "1.0.0"
options:
  computer_name:
    description:
      - The Fully Qualified Domain Name (FQDN) or IP address of the PXE server.
    required: true
    type: str
  credential:
    description:
      - The VMM Run As Account credential to use for adding or removing the PXE server.
      - Required when I(state=present) to add the server.
      - Required when I(state=absent) to uninstall the VMM agent from the PXE server.
    type: dict
    suboptions:
      name:
        description:
          - The name of the VMM Run As Account.
        required: true
        type: str
  description:
    description:
      - A description for the PXE server.
    type: str
  state:
    description:
      - The desired state of the PXE server.
    choices: [ absent, present ]
    default: present
    type: str
  force:
    description:
      - Forces the removal of the PXE server from VMM even if the agent cannot be uninstalled.
      - Only used when I(state=absent).
    type: bool
    default: false
author:
  - Steve Fulmer (@stevefulmer)
'''

EXAMPLES = r'''
- name: Add a PXE server
  microsoft.scvmm.scvmm_pxe_server:
    computer_name: pxe01.contoso.com
    credential:
      name: "PXE Admin Account"
    description: "Main PXE server for bare-metal deployment"
    state: present

- name: Remove a PXE server
  microsoft.scvmm.scvmm_pxe_server:
    computer_name: pxe01.contoso.com
    credential:
      name: "PXE Admin Account"
    state: absent
'''

RETURN = r'''
pxe_server:
  description: Details about the PXE server.
  returned: always
  type: dict
  sample: {
    "computer_name": "pxe01.contoso.com",
    "description": "Main PXE server",
    "id": "70966f98-4c92-426c-8438-662235948972",
    "is_connected": true,
    "version": "10.19.2505.0"
  }
'''
