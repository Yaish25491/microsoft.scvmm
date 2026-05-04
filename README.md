# Microsoft SCVMM Ansible Collection

[![CI](https://github.com/ansible-collections/microsoft.scvmm/workflows/CI/badge.svg)](https://github.com/ansible-collections/microsoft.scvmm/actions)
[![Codecov](https://img.shields.io/codecov/c/github/ansible-collections/microsoft.scvmm)](https://codecov.io/gh/ansible-collections/microsoft.scvmm)

This is the official `microsoft.scvmm` Ansible Collection. It provides modules for automating and managing Microsoft System Center Virtual Machine Manager (SCVMM) infrastructure, including virtual machines, templates, clouds, host groups, networking, and storage.

## Requirements

*   Ansible Core >= 2.15.0
*   `ansible.windows` collection >= 2.0.0
*   Target hosts require WinRM connectivity and must be manageable via PowerShell cmdlets provided by SCVMM.

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

This collection includes modules for managing:
*   **Virtual Machines:** Lifecycle, Hardware modifications
*   **Infrastructure:** Clouds, Host Groups, Host Inventory
*   **Networking:** Logical Networks, VM Networks, Network Isolation
*   **Storage:** VHDs, Storage Classifications
*   **Templates & Day 2:** VM Templates, Checkpoints, Availability Sets

*(For a full list of modules and their documentation, please refer to the module index once published).*

## Usage Example

```yaml
- name: Example playbook to manage an SCVMM VM
  hosts: scvmm_servers
  tasks:
    - name: Ensure a virtual machine is started
      microsoft.scvmm.scvmm_vm:
        name: WebServer01
        state: started
```

## Testing

For local testing, we recommend using `ansible-test` to run sanity and unit tests:

```bash
ansible-test sanity
ansible-test units --docker default
```

Integration tests require a live SCVMM 2022 environment and WinRM configured.

## Contributing

We welcome contributions! Please see our [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute to this collection.

## License

GNU General Public License v3.0 or later.
