#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_ip_pool_info
short_description: Gather information about SCVMM static IP address pools
description:
  - Gather information about System Center Virtual Machine Manager (SCVMM) static IP address pools.
  - Wraps the Get-SCStaticIPAddressPool cmdlet.
options:
  name:
    description:
      - The name of the static IP address pool to retrieve info for.
      - If not specified, all static IP address pools are returned.
    type: str
author:
  - Ansible Community (@ansible-community)
'''

EXAMPLES = r'''
- name: Get info for a specific static IP address pool
  microsoft.scvmm.scvmm_ip_pool_info:
    name: "Corp_IP_Pool"

- name: Get info for all static IP address pools
  microsoft.scvmm.scvmm_ip_pool_info:
'''

RETURN = r'''
ip_pools:
  description: A list of SCVMM static IP address pools matching the criteria.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: The name of the IP address pool.
      type: str
      sample: "Corp_IP_Pool"
    id:
      description: The unique identifier of the IP address pool.
      type: str
      sample: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
    description:
      description: The description of the IP address pool.
      type: str
      sample: "Production IP address pool"
    subnet:
      description: The network subnet (e.g., 10.0.0.0/24).
      type: str
      sample: "10.0.0.0/24"
    vlan:
      description: The VLAN ID associated with the pool.
      type: int
      sample: 10
    ip_address_range_start:
      description: The first IP address in the pool range.
      type: str
      sample: "10.0.0.10"
    ip_address_range_end:
      description: The last IP address in the pool range.
      type: str
      sample: "10.0.0.100"
    ip_address_reserved_set:
      description: A range of IP addresses reserved for other uses.
      type: str
      sample: "10.0.0.10-10.0.0.20"
    vip_address_set:
      description: IP addresses reserved for Load Balancer Virtual IPs (VIPs).
      type: str
      sample: "10.0.0.50-10.0.0.60"
    dnssuffix:
      description: The primary DNS suffix for the pool.
      type: str
      sample: "contoso.com"
    dns_search_suffixes:
      description: An array of additional DNS search suffixes.
      type: list
      elements: str
      sample: ["corp.contoso.com"]
    enable_netbios:
      description: Whether NetBIOS over TCP/IP is enabled.
      type: bool
      sample: true
    logical_network_definition:
      description: The Network Site (Logical Network Definition) this pool is associated with.
      type: str
      sample: "Production Site"
    vm_subnet:
      description: The specific VM Subnet object name.
      type: str
      sample: "Tenant01_Subnet"
    default_gateways:
      description: A list of default gateways.
      type: list
      elements: dict
      contains:
        address:
          description: The gateway IP address.
          type: str
        metric:
          description: The gateway metric.
          type: int
    dns_servers:
      description: A list of DNS server IP addresses.
      type: list
      elements: str
      sample: ["10.0.0.5", "10.0.0.6"]
    wins_servers:
      description: A list of WINS server IP addresses.
      type: list
      elements: str
      sample: ["10.0.0.7"]
'''
