#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Hen Yaish
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_update_server_info
short_description: Gather information about SCVMM update servers
description:
  - Gathers information about update servers (WSUS) in System Center Virtual Machine Manager (SCVMM).
version_added: "1.0.0"
options:
  computer_name:
    description:
      - The Fully Qualified Domain Name (FQDN), IP address, or NetBIOS name of the update server to gather info about.
      - If not specified, information about all update servers is returned.
    type: str
author:
  - Hen Yaish (@Yaish25491)
'''

EXAMPLES = r'''
- name: Gather info about all update servers
  microsoft.scvmm.scvmm_update_server_info:
  register: update_server_info

- name: Gather info about a specific update server
  microsoft.scvmm.scvmm_update_server_info:
    computer_name: wsus01.contoso.com
  register: update_server_info
'''

RETURN = r'''
update_servers:
  description: A list of update servers and their details.
  returned: always
  type: list
  elements: dict
  sample: [
    {
      "computer_name": "wsus01.contoso.com",
      "id": "70966f98-4c92-426c-8438-662235948972",
      "tcp_port": 8530,
      "use_ssl_connection": false,
      "proxy_server_name": null,
      "proxy_server_port": 80,
      "update_classifications": ["Security Updates", "Critical Updates"],
      "update_categories": ["Windows Server 2022"],
      "update_languages": ["en-US"],
      "is_connected": true
    }
  ]
'''
