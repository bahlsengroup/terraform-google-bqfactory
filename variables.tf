# Copyright 2026 Bahlsen GmbH & Co. KG
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

variable "project_id" {
  description = "The ID of the project where BigQuery resources will be created."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]", var.project_id))
    error_message = "Invlaid project_id! It must be 6 to 30 lowercase letters, digits, or hyphens. It must start with a letter. Trailing hyphens are prohibited."
  }
}

variable "config_path" {
  description = "The path to the directory containing BigQuery configuration JSON files."
  type        = string

  validation {
    condition     = length(var.config_path) > 0 && !can(regex("/$", var.config_path))
    error_message = "The config_path must not be empty and must not end with a trailing slash."
  }
}
