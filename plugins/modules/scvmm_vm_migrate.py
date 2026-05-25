# -*- coding: utf-8 -*-

# Copyright: (c) 2026, Ansible Collections Team (@ansible-collections)
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_vm_migrate
short_description: Migrate a virtual machine in SCVMM
description:
    - Migrate a virtual machine between hosts or clusters in System Center Virtual Machine Manager (SCVMM).
    - Supports live migration and storage migration.
version_added: "1.0.0"
author:
    - Steve Fulmer (@stevefulmer)
options:
    name:
        description:
            - The name of the virtual machine to migrate.
        type: str
        required: true
    vm_host:
        description:
            - The target host for the virtual machine migration.
            - Required if I(vm_cluster) or I(vm_host_group) is not specified.
        type: str
    vm_host_group:
        description:
            - The target host group. If specified, the module will attempt to find the best host within this group.
        type: str
    vm_cluster:
        description:
            - The target cluster. If specified, the module will attempt to find the best host within this cluster.
        type: str
    path:
        description:
            - The destination path for the virtual machine files on the target host.
        type: str
    vmm_server:
        description:
            - The VMM server to connect to.
        type: str
requirements:
    - VirtualMachineManager PowerShell module
'''

EXAMPLES = r'''
- name: Migrate VM to a specific host
  microsoft.scvmm.scvmm_vm_migrate:
    name: VM01
    vm_host: Host02
    path: D:\VMs

- name: Migrate VM to a host group (automatically selects best host)
  microsoft.scvmm.scvmm_vm_migrate:
    name: VM01
    vm_host_group: Production-Cluster-Group
'''

RETURN = r'''
vm:
    description: Information about the migrated virtual machine.
    returned: success
    type: dict
    contains:
        name:
            description: Virtual machine name.
            type: str
        id:
            description: Virtual machine GUID.
            type: str
        status:
            description: Virtual machine status.
            type: str
        vm_host:
            description: The host the VM is currently on.
            type: str
'''
