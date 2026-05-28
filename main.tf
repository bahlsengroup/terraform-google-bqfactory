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

# Local variables to process configuration files and prepare resource maps.
locals {
  # Discover all JSON configuration files in the root of the config_path.
  # These files define the BigQuery datasets.
  bigquery_dataset_configs = fileset(var.config_path, "*.json")

  # Decode dataset configurations into a map keyed by dataset_id.
  bigquery_datasets = { for config in local.bigquery_dataset_configs :
    trimsuffix(basename(config), ".json") => jsondecode(file("${var.config_path}/${config}"))
  }

  # Discover all JSON configuration files in subdirectories of the config_path.
  # These files define the BigQuery tables, where the subdirectory name is the dataset_id.
  bigquery_table_configs = fileset(var.config_path, "*/*.json")

  # Process all table configurations into a unified map.
  bigquery_tables_all = { for config in local.bigquery_table_configs :
    trimsuffix(config, ".json") => merge(
      {
        dataset_id = dirname(config)
        table_id   = trimsuffix(basename(config), ".json")
      },
      jsondecode(file("${var.config_path}/${config}"))
    )
  }

  # Managed tables are those that provide a 'schema' definition.
  bigquery_tables_managed = { for k, v in local.bigquery_tables_all : k => v if v.schema != null }

  # Unmanaged tables are those without a 'schema' definition (e.g., views or externally managed tables).
  bigquery_tables_unmanaged = { for k, v in local.bigquery_tables_all : k => v if v.schema == null }
}

# Resource to manage BigQuery datasets based on JSON configurations.
resource "google_bigquery_dataset" "this" {
  for_each                   = local.bigquery_datasets
  project                    = var.project_id
  dataset_id                 = each.key
  description                = lookup(each.value, "description", null)
  location                   = lookup(each.value, "location", "EU") # Default to EU if not specified in JSON
  delete_contents_on_destroy = lookup(each.value, "delete_contents_on_destroy", false)

  # Authoritative access blocks for standard project roles.
  access {
    special_group = "projectOwners"
    role          = "OWNER"
  }

  access {
    special_group = "projectWriters"
    role          = "WRITER"
  }

  access {
    special_group = "projectReaders"
    role          = "READER"
  }

  # Dynamic access blocks for custom permissions defined in the dataset JSON.
  dynamic "access" {
    for_each = lookup(each.value, "access", [])
    content {
      user_by_email = lookup(access.value, "user_by_email", null) != null ? replace(
      lookup(access.value, "user_by_email", null), "{ENV}", var.env) : null
      group_by_email = lookup(access.value, "group_by_email", null) != null ? replace(
      lookup(access.value, "group_by_email", null), "{ENV}", var.env) : null
      role = access.value.role
    }
  }
}

# Resource to manage BigQuery tables that have a schema defined.
resource "google_bigquery_table" "this" {
  for_each                 = local.bigquery_tables_managed
  project                  = var.project_id
  dataset_id               = each.value.dataset_id
  table_id                 = each.value.table_id
  schema                   = jsonencode(each.value.schema)
  require_partition_filter = lookup(each.value, "require_partition_filter", null)

  # Configure time-based partitioning if defined in the table JSON.
  dynamic "time_partitioning" {
    for_each = lookup(each.value, "time_partitioning", null) != null ? [each.value.time_partitioning] : []

    content {
      type          = time_partitioning.value.type
      field         = lookup(time_partitioning.value, "field", null)
      expiration_ms = lookup(time_partitioning.value, "expiration_ms", null)
    }
  }

  # Configure external data sources (e.g., CSV, Parquet, Google Sheets) if defined.
  dynamic "external_data_configuration" {
    for_each = lookup(each.value, "external_data_configuration", null) != null ? [each.value.external_data_configuration] : []
    content {
      autodetect            = lookup(external_data_configuration.value, "autodetect", null)
      source_format         = lookup(external_data_configuration.value, "source_format", null)
      source_uris           = lookup(external_data_configuration.value, "source_uris", null)
      ignore_unknown_values = lookup(external_data_configuration.value, "ignore_unknown_values", null)
      max_bad_records       = lookup(external_data_configuration.value, "max_bad_records", null)

      dynamic "csv_options" {
        for_each = lookup(external_data_configuration.value, "csv_options", null) != null ? [external_data_configuration.value.csv_options] : []
        content {
          quote                 = lookup(csv_options.value, "quote", null)
          allow_jagged_rows     = lookup(csv_options.value, "allow_jagged_rows", null)
          allow_quoted_newlines = lookup(csv_options.value, "allow_quoted_newlines", null)
          encoding              = lookup(csv_options.value, "encoding", null)
          field_delimiter       = lookup(csv_options.value, "field_delimiter", null)
          skip_leading_rows     = lookup(csv_options.value, "skip_leading_rows", null)
        }
      }

      dynamic "google_sheets_options" {
        for_each = lookup(external_data_configuration.value, "google_sheets_options", null) != null ? [external_data_configuration.value.google_sheets_options] : []
        content {
          skip_leading_rows = lookup(google_sheets_options.value, "skip_leading_rows", null)
          range             = lookup(google_sheets_options.value, "range", null)
        }
      }
    }
  }

  # Ensure that tables are only created in datasets managed by this module.
  lifecycle {
    precondition {
      condition     = contains(keys(local.bigquery_datasets), each.value.dataset_id)
      error_message = "Cannot create table '${each.value.table_id}' because the dataset '${each.value.dataset_id}' is not managed by this module."
    }
  }
}

# Fetch information for tables not managed by this module
data "google_bigquery_table" "unmanaged" {
  for_each   = local.bigquery_tables_unmanaged
  project    = var.project_id
  dataset_id = each.value.dataset_id
  table_id   = each.value.table_id
}

# Construct IAM policy data for unmanaged tables that have 'table_iam_roles' defined.
data "google_iam_policy" "table_iam_policy_unmanaged" {
  for_each = {
    for k, table in local.bigquery_tables_unmanaged : k => table
    if lookup(table, "table_iam_roles", null) != null
  }

  dynamic "binding" {
    for_each = each.value.table_iam_roles
    content {
      role    = binding.key
      members = binding.value
    }
  }
}

# Construct IAM policy data for managed tables that have 'table_iam_roles' defined.
data "google_iam_policy" "table_iam_policy_managed" {
  for_each = {
    for k, table in local.bigquery_tables_managed : k => table
    if lookup(table, "table_iam_roles", null) != null
  }

  dynamic "binding" {
    for_each = each.value.table_iam_roles
    content {
      role    = binding.key
      members = binding.value
    }
  }
}

# Apply IAM policies to managed tables.
resource "google_bigquery_table_iam_policy" "managed_table_iam_policies" {
  for_each = data.google_iam_policy.table_iam_policy_managed

  project     = var.project_id
  dataset_id  = google_bigquery_table.this[each.key].dataset_id
  table_id    = google_bigquery_table.this[each.key].table_id
  policy_data = each.value.policy_data
}

# Apply IAM policies to unmanaged tables.
resource "google_bigquery_table_iam_policy" "unmanaged_table_iam_policies" {
  for_each = data.google_iam_policy.table_iam_policy_unmanaged

  project     = var.project_id
  dataset_id  = data.google_bigquery_table.unmanaged[each.key].dataset_id
  table_id    = data.google_bigquery_table.unmanaged[each.key].table_id
  policy_data = each.value.policy_data
}
