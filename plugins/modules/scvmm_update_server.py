#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_update_server
short_description: Manage SCVMM Update Servers
description:
  - Manage WSUS or Configuration Manager update servers in System Center Virtual Machine Manager (SCVMM).
  - Wraps Add-SCUpdateServer, Set-SCUpdateServer, and Remove-SCUpdateServer.
options:
  computer_name:
    description:
      - The FQDN or IP of the update server.
    type: str
    required: true
  port:
    description:
      - The port used to connect to the update server.
    type: int
    default: 8530
  use_ssl:
    description:
      - Whether to use SSL for the connection.
    type: bool
    default: false
  credential:
    description:
      - The name of the Run As Account to use for connecting.
    type: str
  state:
    description:
      - The desired state of the update server.
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
- name: Add a WSUS server
  microsoft.scvmm.scvmm_update_server:
    computer_name: "wsus.contoso.com"
    port: 8530
    state: present
'''

RETURN = r'''
update_server:
  description: Information about the update server.
  returned: always
  type: dict
'''
