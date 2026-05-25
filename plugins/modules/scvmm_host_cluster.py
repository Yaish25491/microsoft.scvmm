#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_host_cluster
short_description: Manage SCVMM Host Clusters
description:
  - Manage System Center Virtual Machine Manager (SCVMM) Host Clusters.
  - Supports adding existing failover clusters to VMM, modifying properties, and removing them from VMM management.
  - Wraps Add-SCVMHostCluster, Set-SCVMHostCluster, and Remove-SCVMHostCluster PowerShell cmdlets.
version_added: "1.0.0"
author:
  - Gemini (@gemini)
options:
  name:
    description:
      - The FQDN or name of the cluster to manage.
    type: str
    required: true
  state:
    description:
      - Desired state of the host cluster.
    type: str
    choices: [ absent, present ]
    default: present
  host_group:
    description:
      - The name of the host group to place the cluster in.
      - Required when I(state=present) and the cluster is being added to VMM.
    type: str
  run_as_account:
    description:
      - The name of the Run As account used to manage the cluster.
      - Required when I(state=present) and the cluster is being added to VMM.
    type: str
  cluster_reserve:
    description:
      - Number of host failures the cluster can sustain before being marked "over-committed."
    type: int
  vm_paths:
    description:
      - Default paths for virtual machine files. Multiple paths can be separated by a pipe character (e.g., C:\VMs|D:\VMs).
    type: str
  remote_connect_enabled:
    description:
      - Enables or disables remote connections (VMConnect).
    type: bool
  remote_connect_port:
    description:
      - TCP port for remote connections.
    type: int
  description:
    description:
      - Description of the host cluster.
    type: str
'''

EXAMPLES = r'''
- name: Add an existing failover cluster to SCVMM
  microsoft.scvmm.scvmm_host_cluster:
    name: "cluster01.contoso.com"
    state: present
    host_group: "All Hosts\\Datacenter01"
    run_as_account: "ClusterAdmin"
    cluster_reserve: 1

- name: Update cluster properties
  microsoft.scvmm.scvmm_host_cluster:
    name: "cluster01.contoso.com"
    cluster_reserve: 2
    remote_connect_enabled: true

- name: Remove a cluster from VMM management
  microsoft.scvmm.scvmm_host_cluster:
    name: "cluster01.contoso.com"
    state: absent
'''

RETURN = r'''
# Default return values
'''
