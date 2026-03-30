variable "yc_token" {
  type        = string
  description = "Yandex Cloud IAM token"
  sensitive   = true
}

variable "cloud_id" {
  type        = string
  description = "Yandex Cloud ID"
}

variable "folder_id" {
  type        = string
  description = "Yandex Folder ID"
}

variable "default_zone" {
  type        = string
  description = "Default availability zone"
  default     = "ru-central1-a"
}

variable "zone_workers" {
  type = list(string)
  description = "zones for workers"
  default = ["ru-central1-a", "ru-central1-b"]
}