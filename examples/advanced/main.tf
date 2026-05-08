module "advanced_bq" {
  source = "../../"

  project_id  = var.project_id
  config_path = "${path.module}/config"
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

output "datasets" {
  value = module.advanced_bq.datasets
}

output "tables" {
  value = module.advanced_bq.tables
}
