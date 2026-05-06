#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Steve Fulmer
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_host_cluster_info
short_description: Gather information about SCVMM Host Clusters
description:
  - Gather information about System Center Virtual Machine Manager (SCVMM) Host Clusters.
  - This module wraps the C(Get-SCVMHostCluster) PowerShell cmdlet.
version_added: "1.0.0"
author:
  - Gemini (@gemini)
options:
  name:
    description:
      - The name of the SCVMM Host Cluster to filter by.
    type: str
  host_group:
    description:
      - The name of the host group to filter clusters by.
    type: str
'''

EXAMPLES = r'''
- name: Gather information about all Host Clusters
  microsoft.scvmm.scvmm_host_cluster_info:

- name: Gather information about a specific Host Cluster by name
  microsoft.scvmm.scvmm_host_cluster_info:
    name: "Cluster01"

- name: Gather information about Host Clusters in a specific Host Group
  microsoft.scvmm.scvmm_host_cluster_info:
    host_group: "All Hosts\\Datacenter01"
'''

RETURN = r'''
host_clusters:
  description: A list of dictionaries containing information about the SCVMM Host Clusters.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: The name of the host cluster.
      type: str
      sample: "Cluster01"
    id:
      description: The unique identifier (GUID) of the host cluster.
      type: str
      sample: "12345678-1234-1234-1234-123456789012"
    cluster_reserve:
      description: The configured host failure tolerance.
      type: int
      sample: 1
    is_over_committed:
      description: Boolean indicating if the cluster has exceeded its reserve capacity.
      type: bool
      sample: false
    nodes:
      description: A list of host names that are members of the cluster.
      type: list
      elements: str
      sample: ["Host01.contoso.com", "Host02.contoso.com"]
    vm_host_group:
      description: The name of the host group the cluster belongs to.
      type: str
      sample: "All Hosts\\Datacenter01"
    vm_paths:
      description: The default storage paths for virtual machines.
      type: str
      sample: "C:\\ClusterStorage\\Volume1|D:\\VMs"
    remote_connect_enabled:
      description: Whether remote console access is enabled.
      type: bool
      sample: true
    remote_connect_port:
      description: TCP port for remote connections.
      type: int
      sample: 5900
    virtualization_platform:
      description: The hypervisor type (e.g., HyperV, VMwareESX, XenServer).
      type: str
      sample: "HyperV"
'''
