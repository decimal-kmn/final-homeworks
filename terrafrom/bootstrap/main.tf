# Create a service account for Terraform automation
resource "yandex_iam_service_account" "terraform_sa" {
  name        = "terraform-automation-sa"
  description = "Service account for Terraform infrastructure management"
}

# Grant necessary permissions to the service account
# vpc.admin allows managing network resources
resource "yandex_resourcemanager_folder_iam_member" "sa_vpc_admin" {
  folder_id = var.folder_id
  role      = "vpc.admin"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

# storage.editor allows managing storage buckets and objects (for state file)
resource "yandex_resourcemanager_folder_iam_member" "sa_storage_editor" {
  folder_id = var.folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.terraform_sa.id}"
}

# Create static access keys for the service account (for S3 backend access)
resource "yandex_iam_service_account_static_access_key" "terraform_sa_key" {
  service_account_id = yandex_iam_service_account.terraform_sa.id
  description        = "Static access key for Terraform S3 backend"
}

# Create S3 bucket for Terraform state storage
resource "yandex_storage_bucket" "terraform_state" {
  folder_id  = var.folder_id
  bucket = "${var.folder_id}-terraform-state"
  # Enable versioning to protect state file integrity
  versioning {
    enabled = true
  }
  force_destroy = true # я понимаю что это такое
}

# Outputs for use in the next stage
output "sa_access_key" {
  value     = yandex_iam_service_account_static_access_key.terraform_sa_key.access_key
  sensitive = true
}

output "sa_secret_key" {
  value     = yandex_iam_service_account_static_access_key.terraform_sa_key.secret_key
  sensitive = true
}

output "bucket_name" {
  value = yandex_storage_bucket.terraform_state.bucket
}

output "sa_account_id" {
  value = yandex_iam_service_account.terraform_sa.id
  sensitive = true
}