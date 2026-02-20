variable "roles" {
  description = "Map of IAM roles to create"
  type = map(object({
    name                  = string
    description           = optional(string, "")
    assume_role_policy    = object({})
    max_session_duration  = optional(number, 3600)
  }))
  default = {}
}

variable "policies" {
  description = "Map of IAM policies to create"
  type = map(object({
    name        = string
    description = optional(string, "")
    policy      = string
  }))
  default = {}
}

variable "role_policy_attachments" {
  description = "Map of policy attachments to roles"
  type = map(object({
    role_name   = string
    policy_name = optional(string)
    policy_arn  = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for attachment in var.role_policy_attachments :
      (attachment.policy_name != null) || (attachment.policy_arn != null)
    ])
    error_message = "Each role policy attachment must have either policy_name or policy_arn specified."
  }
}

variable "inline_role_policies" {
  description = "Map of inline policies to attach to roles"
  type = map(object({
    name      = string
    role_name = string
    policy    = object({})
  }))
  default = {}
}

variable "users" {
  description = "Map of IAM users to create"
  type = map(object({
    name                 = string
    path                 = optional(string, "/")
    force_destroy        = optional(bool, false)
    permissions_boundary = optional(string)
  }))
  default = {}
}

variable "user_policy_attachments" {
  description = "Map of policy attachments to users"
  type = map(object({
    user_name   = string
    policy_name = optional(string)
    policy_arn  = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for attachment in var.user_policy_attachments :
      (attachment.policy_name != null) || (attachment.policy_arn != null)
    ])
    error_message = "Each user policy attachment must have either policy_name or policy_arn specified."
  }
}

variable "inline_user_policies" {
  description = "Map of inline policies to attach to users"
  type = map(object({
    name      = string
    user_name = string
    policy    = object({})
  }))
  default = {}
}

variable "user_access_keys" {
  description = "Map of users for which to create access keys"
  type = map(object({
    user_name = string
  }))
  default = {}
}

variable "groups" {
  description = "Map of IAM groups to create"
  type = map(object({
    name = string
    path = optional(string, "/")
  }))
  default = {}
}

variable "group_policy_attachments" {
  description = "Map of policy attachments to groups"
  type = map(object({
    group_name  = string
    policy_name = optional(string)
    policy_arn  = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for attachment in var.group_policy_attachments :
      (attachment.policy_name != null) || (attachment.policy_arn != null)
    ])
    error_message = "Each group policy attachment must have either policy_name or policy_arn specified."
  }
}

variable "user_group_memberships" {
  description = "Map of user group memberships"
  type = map(object({
    user_name  = string
    group_names = list(string)
  }))
  default = {}
}

variable "instance_profiles" {
  description = "Map of IAM instance profiles to create"
  type = map(object({
    name      = string
    role_name = string
  }))
  default = {}
}

variable "cross_account_roles" {
  description = "Map of cross-account IAM roles"
  type = map(object({
    name               = string
    description        = optional(string, "")
    assume_role_policy = object({})
  }))
  default = {}
}

variable "cross_account_role_policies" {
  description = "Map of policy attachments to cross-account roles"
  type = map(object({
    role_name   = string
    policy_name = optional(string)
    policy_arn  = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for attachment in var.cross_account_role_policies :
      (attachment.policy_name != null) || (attachment.policy_arn != null)
    ])
    error_message = "Each cross-account role policy attachment must have either policy_name or policy_arn specified."
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
