# Microsoft SCVMM Ansible Collection

[![CI](https://github.com/ansible-collections/microsoft.scvmm/workflows/CI/badge.svg)](https://github.com/ansible-collections/microsoft.scvmm/actions)
[![Codecov](https://img.shields.io/codecov/c/github/ansible-collections/microsoft.scvmm)](https://codecov.io/gh/ansible-collections/microsoft.scvmm)

This is the official `microsoft.scvmm` Ansible Collection. It provides an exhaustive suite of 97 modules for automating and managing Microsoft System Center Virtual Machine Manager (SCVMM) infrastructure, including virtual machines, templates, bare metal provisioning, clouds, host groups, networking, storage, compliance, and RBAC.

> **Note:** This collection was architected and implemented as part of the ANSTRAT-2120 initiative to provide full edge-to-edge management of SCVMM from Ansible.

## Requirements

*   Ansible Core >= 2.15.0
*   `ansible.windows` collection >= 2.0.0
*   Target Windows hosts require WinRM connectivity.
*   Target Windows hosts must have the `VirtualMachineManager` PowerShell module installed (typically installed alongside the SCVMM Console).

## Installation

You can install the collection from Ansible Galaxy:

```bash
ansible-galaxy collection install microsoft.scvmm
```

To install directly from the source repository:

```bash
ansible-galaxy collection install git+https://github.com/ansible-collections/microsoft.scvmm.git
```

## Included Content

This collection includes 97 modules categorized into the following domains:

*   **Core Compute & Lifecycle:** Manage VMs (`scvmm_vm`), power states (`scvmm_vm_state`), checkpoints, migrations, cloning, DVD drives, and SCSI adapters.
*   **Infrastructure Management:** Private Clouds (`scvmm_cloud`), Host Groups (`scvmm_host_group`), VM Hosts (`scvmm_host`), Clusters, and Capacity.
*   **Network Management:** Logical Networks, VM Networks, Subnets, Logical Switches, Port Classifications, MAC/IP Pools, and Load Balancers.
*   **Storage Management:** Storage Pools, Providers, Classifications, File Shares, and Virtual Hard Disks.
*   **Bare Metal Provisioning & Profiles:** PXE Servers, Physical Computer Profiles, Hardware Profiles, Guest OS Profiles, Application Profiles, and Capability Profiles.
*   **Update & Compliance:** Update Servers (WSUS), Baselines, and Compliance Scans.
*   **Service Templates & Apps:** Service Templates, deployed Services, and SQL Profiles.
*   **RBAC & Operations:** User Roles, Run As Accounts, Quotas, Jobs, and Custom Properties.
*   **Library Management:** Library Servers, Shares, ISOs, Scripts, and Custom Resources.

All modules are paired with a corresponding `_info` module to gather structured facts about the resources (e.g., `scvmm_vm` and `scvmm_vm_info`).

## Usage Example

```yaml
- name: Example playbook to manage an SCVMM VM and Logical Network
  hosts: scvmm_servers
  tasks:
    - name: Ensure a logical network exists
      microsoft.scvmm.scvmm_logical_network:
        name: "Corp_Network"
        description: "Corporate Isolated Network"
        state: present

    - name: Create a virtual machine in a host group
      microsoft.scvmm.scvmm_vm:
        name: "WebServer01"
        host_group: "All Hosts\\Production"
        memory_mb: 4096
        cpu_count: 2
        state: present

    - name: Ensure the virtual machine is running
      microsoft.scvmm.scvmm_vm_state:
        name: "WebServer01"
        state: started
```

## Architecture

All modules in this collection utilize a "Split-Plugin" architecture:
- Python (`.py`) files handle Ansible argument specs and documentation.
- PowerShell (`.ps1`) files handle the execution logic using the `VirtualMachineManager` snap-in.

To maintain perfect output consistency, all object-to-dictionary data conversion is centralized in the shared `plugins/module_utils/scvmm.psm1` utility.

## Testing

For local testing, we recommend using `ansible-test` to run sanity and integration tests:

```bash
# Run sanity checks
ansible-test sanity --docker default

# Run Windows integration tests against an SCVMM target
ansible-test windows-integration --docker default
```

Integration tests require a live SCVMM 2022+ environment and an `inventory.winrm` file configured with your target test hosts.

## Contributing

We welcome contributions! Please see our [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute to this collection.

## License

GNU General Public License v3.0 or later.
