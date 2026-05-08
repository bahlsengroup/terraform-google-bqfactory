<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| config_path | The path to the directory containing BigQuery configuration JSON files. | `string` | n/a | yes |
| project_id | The ID of the project where BigQuery resources will be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| datasets | A map of the created BigQuery datasets. |
| tables | A map of the created BigQuery tables. |
<!-- END_TF_DOCS -->
