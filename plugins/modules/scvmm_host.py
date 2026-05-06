#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_host
short_description: Manage SCVMM VM Hosts
description:
    - Manage System Center Virtual Machine Manager (SCVMM) VM Hosts using Add-SCVMHost, Set-SCVMHost, and Remove-SCVMHost cmdlets.
version_added: "1.0.0"
author:
    - Steve Fulmer (@stevefulmer)
options:
    name:
        description:
            - The FQDN or IP address of the computer to add/manage.
        type: str
        required: true
        aliases: [computer_name]
    host_group:
        description:
            - The host group container where the host will be placed.
            - Required when O(state=present) and the host is being added.
        type: str
    description:
        description:
            - A description for the host.
        type: str
    state:
        description:
            - The desired state of the host.
        type: str
        choices: [absent, present]
        default: present
'''

EXAMPLES = r'''
- name: Add a new SCVMM host
  microsoft.scvmm.scvmm_host:
    name: vmhost01.contoso.com
    host_group: Production
    description: Primary Hyper-V Host
    state: present

- name: Update host description
  microsoft.scvmm.scvmm_host:
    name: vmhost01.contoso.com
    description: Updated Production Host
    state: present

- name: Remove an SCVMM host
  microsoft.scvmm.scvmm_host:
    name: vmhost01.contoso.com
    state: absent
'''

RETURN = r'''
host:
    description: Information about the SCVMM host.
    returned: always
    type: dict
    sample:
        name: vmhost01.contoso.com
        id: 56789abc-def0-1234-5678-9abcdef01234
        description: Primary Hyper-V Host
        host_group: Production
        state: Responding
'''
