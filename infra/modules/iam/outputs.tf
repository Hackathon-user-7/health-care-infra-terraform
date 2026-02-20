output "roles" {
  description = "Map of IAM roles created"
  value = {
    for k, v in aws_iam_role.roles : k => {
      name = v.name
      arn  = v.arn
      id   = v.id
    }
  }
}

output "policies" {
  description = "Map of IAM policies created"
  value = {
    for k, v in aws_iam_policy.policies : k => {
      name = v.name
      arn  = v.arn
      id   = v.id
    }
  }
}

output "users" {
  description = "Map of IAM users created"
  value = {
    for k, v in aws_iam_user.users : k => {
      name = v.name
      arn  = v.arn
      id   = v.id
    }
  }
  sensitive = true
}

output "user_access_keys" {
  description = "Map of IAM user access keys (passwords are sensitive)"
  value = {
    for k, v in aws_iam_access_key.user_keys : k => {
      user_name = v.user
      access_key_id = v.id
      # Note: secret_access_key is not included in output for security reasons
      # Save it securely after creation
    }
  }
  sensitive = true
}

output "groups" {
  description = "Map of IAM groups created"
  value = {
    for k, v in aws_iam_group.groups : k => {
      name = v.name
      arn  = v.arn
      id   = v.id
    }
  }
}

output "instance_profiles" {
  description = "Map of IAM instance profiles created"
  value = {
    for k, v in aws_iam_instance_profile.instance_profiles : k => {
      name = v.name
      arn  = v.arn
      id   = v.id
    }
  }
}

output "cross_account_roles" {
  description = "Map of cross-account IAM roles created"
  value = {
    for k, v in aws_iam_role.cross_account_roles : k => {
      name = v.name
      arn  = v.arn
      id   = v.id
    }
  }
}

output "role_arns" {
  description = "List of all IAM role ARNs"
  value = concat(
    [for role in aws_iam_role.roles : role.arn],
    [for role in aws_iam_role.cross_account_roles : role.arn]
  )
}

output "user_arns" {
  description = "List of all IAM user ARNs"
  value       = [for user in aws_iam_user.users : user.arn]
}

output "group_arns" {
  description = "List of all IAM group ARNs"
  value       = [for group in aws_iam_group.groups : group.arn]
}

output "policy_arns" {
  description = "List of all IAM policy ARNs"
  value       = [for policy in aws_iam_policy.policies : policy.arn]
}
