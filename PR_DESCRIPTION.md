##### SUMMARY

Refactors the monolithic `scvmm.psm1` utility into domain-specific utilities (e.g., `scvmm_compute.psm1`, `scvmm_network.psm1`) to drastically reduce the WinRM payload size and memory overhead during module execution.

Design & Implementation:

- **Purpose**: Prevent Ansible from transferring 45 distinct object-to-hashtable mapping functions across WinRM when a module only requires 1 or 2, thereby reducing execution time and memory footprint on the SCVMM host.
- **Functionality**: Purged 2 unused functions and migrated 14 single-use functions directly into their respective calling modules.
- **Architecture & Error Handling**: The remaining 29 shared functions were logically categorized and split across 8 targeted `.psm1` domain utilities. The base `scvmm.psm1` file was retained exclusively to handle the universal `Import-SCVMMModule` connection logic.
- **Validation**: All 97 modules were updated to `#Requires` their specific domain utility. The collection was validated locally and successfully passes all `ansible-test sanity` checks.

##### ISSUE TYPE

- Refactoring Pull Request

##### COMPONENT NAME

- `plugins/module_utils/scvmm.psm1`
- `plugins/modules/*` (All 97 modules)