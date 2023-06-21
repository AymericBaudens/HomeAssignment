variable "aiven_project" {
  description = "Aiven project name"
  type        = string
}

variable "aiven_api_token" {
  description = "Aiven api token"
  type        = string
}

variable "aiven_region" {
  description = "Aiven cloud and location to be used"
  type        = string
  default     = "google-europe-west1"
}