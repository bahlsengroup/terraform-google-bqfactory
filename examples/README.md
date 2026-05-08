# 📚 BigQuery Factory Examples

This directory contains functional examples of how to use the BigQuery Factory
module. These examples are designed to show both common use cases and advanced
configurations.

## 📖 Available Examples

| Example                    | Description                       | Key Features                                                                                |
| :------------------------- | :-------------------------------- | :------------------------------------------------------------------------------------------ |
| **[Basic](./basic)**       | Standard dataset and table setup. | Partitioning, schema definition, dataset protection.                                        |
| **[Advanced](./advanced)** | Complex enterprise scenarios.     | External tables (GCS), custom dataset access, table-level IAM for managed/unmanaged tables. |

## 🏗️ General Structure

All examples follow a consistent structure:

- `main.tf`: The Terraform entry point that calls the module.
- `config/`: A directory containing JSON configuration files.
  - `*.json`: Dataset configurations.
  - `[dataset_id]/*.json`: Table configurations for that specific dataset.

## ✨ Best Practices Shown

- **🛡️ Safety First**: Examples demonstrate the use of
  `delete_contents_on_destroy` (defaulting to `false`) to prevent accidental
  data loss.
- **📂 Organization**: Shows how to structure BigQuery configurations in a clean,
  file-based hierarchy.
- **🔐 Authoritative Access**: Demonstrates how to manage dataset-level access
  controls using the `access` block in JSON.
