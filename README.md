# 🏭 Bahlsen BigQuery Factory Module

[FAQ] | [CONTRIBUTING] | [CHANGELOG]

This module simplifies the management of Google BigQuery resources by using a
file-based configuration approach. It allows you to define BigQuery datasets and
tables in JSON files, which the module then provisions and manages
automatically.

<!-- mdformat-toc start --slug=github --no-anchors --maxlevel=6 --minlevel=2 -->

- [✨ Key Features](#%E2%9C%A8-key-features)
- [🚀 Getting Started](#%F0%9F%9A%80-getting-started)
- [🛠️ Usage](#%F0%9F%9B%A0%EF%B8%8F-usage)
- [📖 Examples](#%F0%9F%93%96-examples)
- [🏗️ Configuration Structure](#%F0%9F%8F%97%EF%B8%8F-configuration-structure)
  - [Dataset Configuration (`[dataset_id].json`)](#dataset-configuration-dataset_idjson)
  - [Table Configuration (`[dataset_id]/[table_id].json`)](#table-configuration-dataset_idtable_idjson)
- [📚 References](#%F0%9F%93%9A-references)
- [📄 License](#%F0%9F%93%84-license)

<!-- mdformat-toc end -->

## ✨ Key Features

- **📦 JSON-based Configuration**: Define datasets and tables using simple JSON
  files.
- **🏗️ Automated Dataset Management**: Creates datasets with configurable
  locations, descriptions, and authoritative access controls.
- **📋 Table Management**: Supports both managed tables (with schema) and
  unmanaged tables (like views).
- **🌐 Advanced Table Features**: Supports time-based partitioning and external
  data configurations (CSV, Parquet, Google Sheets).
- **🔐 Table-Level IAM**: Manage IAM roles for both managed and unmanaged tables
  directly in the JSON config.
- **🛡️ Safety First**: Optional `delete_contents_on_destroy` protection for
  datasets to prevent accidental data loss.

## 🚀 Getting Started

To use this module, you need a directory containing your BigQuery
configurations. The module will traverse this directory to discover datasets and
tables.

1. Create a `config/` directory.
1. Define a dataset by creating a JSON file (e.g., `config/my_dataset.json`).
1. Define tables for that dataset by creating a subdirectory and adding JSON
   files (e.g., `config/my_dataset/my_table.json`).

## 🛠️ Usage

```hcl
module "bq_factory" {
  source      = "bahlsengroup/bqfactory/google"
  version     = "~> 0.1"

  project_id  = "your-project-id"
  config_path = "./config"
}
```

## 📖 Examples

Detailed functional examples can be found in the [examples](./examples)
directory:

- [Basic Example](./examples/basic): Standard dataset and table configuration.
- [Advanced Example](./examples/advanced): Custom access controls, external
  tables, and table-level IAM.

## 🏗️ Configuration Structure

### Dataset Configuration (`[dataset_id].json`)

| Field                        | Description                                     | Default |
| :--------------------------- | :---------------------------------------------- | :------ |
| `description`                | Description of the dataset.                     | `null`  |
| `location`                   | GCP location for the dataset.                   | `EU`    |
| `delete_contents_on_destroy` | If true, delete tables when destroying dataset. | `false` |
| `access`                     | List of access control blocks.                  | `[]`    |

### Table Configuration (`[dataset_id]/[table_id].json`)

| Field                         | Description                                                                                                                                 |
| :---------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------ |
| `schema`                      | BigQuery schema definition (Required for managed tables).                                                                                   |
| `require_partition_filter`    | If true, queries over this table require a partition filter.                                                                                |
| `time_partitioning`           | Configuration for time-based partitioning. Supports `type`, `field`, `expiration_ms`.                                                       |
| `external_data_configuration` | Configuration for external data sources. Supports `autodetect`, `source_format`, `source_uris`, `csv_options`, and `google_sheets_options`. |
| `table_iam_roles`             | Map of roles to members for table-level IAM.                                                                                                |

## 📚 References

- **Google Cloud Documentation**:
  - [BigQuery Datasets](https://cloud.google.com/bigquery/docs/datasets-intro)
  - [BigQuery Tables](https://cloud.google.com/bigquery/docs/tables-intro)
  - [BigQuery External Data Sources](https://cloud.google.com/bigquery/docs/external-data-sources)
- **Terraform Provider Documentation**:
  - [`google_bigquery_dataset`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset)
  - [`google_bigquery_table`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_table)

## 📄 License

This project is licensed under the terms of the [Apache License 2.0](LICENSE).

This [terraform] module depends on providers from HashiCorp, Inc. which are
licensed under MPL-2.0:

- [`hashicorp/google`](https://github.com/hashicorp/terraform-provider-google)

[changelog]: ./docs/CHANGELOG.md
[contributing]: docs/CONTRIBUTING.md
[faq]: ./docs/FAQ.md
[terraform]: https://terraform.io/
