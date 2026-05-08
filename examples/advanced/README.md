# 🟡 Advanced BigQuery Factory Example

This example demonstrates more advanced features of the BigQuery Factory module,
including custom access controls, external data configurations, and IAM roles
for both managed and unmanaged tables.

## ✨ Features Demonstrated

1. **🔐 Dataset Access Control**: The `analytics.json` file defines specific IAM
   roles for a group and a user at the dataset level.
1. **🌐 External Tables**: The `external_users.json` file configures a table
   backed by CSV files in Google Cloud Storage.
1. **🔐 Table-Level IAM**:
   - `external_users.json` (Managed): Grants `dataViewer` access to a specific
     group for this table.
   - `legacy_view.json` (Unmanaged): Demonstrates granting IAM roles to a table
     (like a view) that is not directly managed by this module's
     `google_bigquery_table` resource (it uses the `data` source to find it).
1. **🛡️ Safety & Protection**: Demonstrates the use of dataset-level deletion
   protection.

## 🏗️ Configuration Structure

The configuration is stored in the `config/` directory:

- `analytics.json`: Defines the `analytics` dataset with custom `access` blocks.
- `analytics/external_users.json`: Defines an external table with a schema and
  table-level IAM.
- `analytics/legacy_view.json`: Defines an unmanaged table (no `schema` field)
  with table-level IAM.

> [!IMPORTANT]
> For the unmanaged table IAM to work, the table (e.g., `legacy_view`) must
> already exist in the GCP project, as the module uses a data source to locate
> it.
