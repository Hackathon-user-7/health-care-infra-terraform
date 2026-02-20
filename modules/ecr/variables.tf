variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "hackathon-user7"
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type for the repository"
  type        = string
  default     = "AES256"
}

variable "enable_lifecycle_policy" {
  description = "Enable lifecycle policy"
  type        = bool
  default     = true
}

variable "image_count" {
  description = "Number of images to keep"
  type        = number
  default     = 10
}

variable "tags" {
  description = "Tags for the ECR repository"
  type        = map(string)
  default     = {}
}
