# 🟢 Basic BigQuery Factory Example

This example demonstrates the basic usage of the BigQuery Factory module to
create a dataset and a table with a schema and partitioning.

## ✨ Features Demonstrated

1. **🏗️ Resource Creation**: Provisioning a BigQuery dataset and a table from
   JSON configurations.
1. **📅 Time Partitioning**: Configuring daily partitioning on a timestamp field
   with an expiration policy.
1. **📋 Partition Filter**: Enforcing the use of partition filters for query
   optimization and cost control.
1. **🛡️ Dataset Protection**: Using `delete_contents_on_destroy` to prevent
   accidental data loss.

## 🏗️ Configuration Structure

The configuration is stored in the `config/` directory:

- `my_dataset.json`: Defines the `my_dataset` BigQuery dataset.
- `my_dataset/my_table.json`: Defines the `my_table` table within `my_dataset`.
