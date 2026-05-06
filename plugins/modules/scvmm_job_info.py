#!/usr/bin/python
# -*- coding: utf-8 -*-
# Copyright: (c) 2026, Ansible Project
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function
__metaclass__ = type

DOCUMENTATION = r'''
---
module: scvmm_job_info
short_description: Gather information about SCVMM jobs
description:
  - Gather information about System Center Virtual Machine Manager (SCVMM) jobs.
  - Wraps the Get-SCJob cmdlet.
options:
  id:
    description:
      - The unique identifier (GUID) of the job.
    type: str
  name:
    description:
      - The name of the job to retrieve info for.
    type: str
  status:
    description:
      - The status of the jobs to retrieve.
      - Common statuses include C(Running), C(Succeeded), C(Failed), C(Cancelled).
    type: str
author:
  - Ansible Community (@ansible-community)
'''

EXAMPLES = r'''
- name: Get info for all running jobs
  microsoft.scvmm.scvmm_job_info:
    status: Running

- name: Get info for a specific job by ID
  microsoft.scvmm.scvmm_job_info:
    id: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"

- name: Get info for jobs by name
  microsoft.scvmm.scvmm_job_info:
    name: "Refresh virtual machine"
'''

RETURN = r'''
jobs:
  description: A list of SCVMM jobs matching the criteria.
  returned: always
  type: list
  elements: dict
  contains:
    name:
      description: The name of the job.
      type: str
      sample: "Refresh virtual machine"
    id:
      description: The unique identifier of the job.
      type: str
      sample: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
    status:
      description: The current status of the job.
      type: str
      sample: "Succeeded"
    description:
      description: The description of the job.
      type: str
      sample: "Refreshing virtual machine MyVM"
    owner:
      description: The owner of the job.
      type: str
      sample: "CONTOSO\\Admin"
    start_time:
      description: The time the job started.
      type: str
      sample: "2024-05-20T10:00:00Z"
    end_time:
      description: The time the job finished.
      type: str
      sample: "2024-05-20T10:05:00Z"
    is_cancellable:
      description: Whether the job can be cancelled.
      type: bool
      sample: true
    is_restartable:
      description: Whether the job can be restarted.
      type: bool
      sample: false
    result_object_name:
      description: The name of the object the job is acting upon.
      type: str
      sample: "MyVM"
    result_object_id:
      description: The ID of the object the job is acting upon.
      type: str
      sample: "b2c3d4e5-f6a7-8901-bcde-f12345678901"
    progress:
      description: The progress of the job as a percentage.
      type: int
      sample: 100
    error_code:
      description: The error code if the job failed.
      type: int
      sample: 0
    error_summary:
      description: The error summary if the job failed.
      type: str
      sample: ""
'''
