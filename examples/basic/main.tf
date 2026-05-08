module "basic_bq" {
  source = "../../"

  project_id  = var.project_id
  config_path = "${path.module}/config"
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

output "datasets" {
  value = module.basic_bq.datasets
}

output "tables" {
  value = module.basic_bq.tables
}
