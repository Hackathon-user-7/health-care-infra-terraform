# IAM Roles
resource "aws_iam_role" "roles" {
  for_each = var.roles

  name               = each.value.name
  assume_role_policy = jsonencode(each.value.assume_role_policy)
  description        = each.value.description
  max_session_duration = each.value.max_session_duration

  tags = merge(
    var.tags,
    {
      Name = each.value.name
    }
  )
}

# IAM Policies
resource "aws_iam_policy" "policies" {
  for_each = var.policies

  name        = each.value.name
  description = each.value.description
  policy      = each.value.policy

  tags = merge(
    var.tags,
    {
      Name = each.value.name
    }
  )
}

# Attach policies to roles
resource "aws_iam_role_policy_attachment" "role_policies" {
  for_each = var.role_policy_attachments

  role       = aws_iam_role.roles[each.value.role_name].name
  policy_arn = can(aws_iam_policy.policies[each.value.policy_name].arn) ? aws_iam_policy.policies[each.value.policy_name].arn : each.value.policy_arn
}

# Inline policies for roles
resource "aws_iam_role_policy" "inline_role_policies" {
  for_each = var.inline_role_policies

  name   = each.value.name
  role   = aws_iam_role.roles[each.value.role_name].id
  policy = jsonencode(each.value.policy)
}

# IAM Users
resource "aws_iam_user" "users" {
  for_each = var.users

  name                 = each.value.name
  path                 = each.value.path
  force_destroy        = each.value.force_destroy
  permissions_boundary = each.value.permissions_boundary

  tags = merge(
    var.tags,
    {
      Name = each.value.name
    }
  )
}

# Attach policies to users
resource "aws_iam_user_policy_attachment" "user_policies" {
  for_each = var.user_policy_attachments

  user       = aws_iam_user.users[each.value.user_name].name
  policy_arn = can(aws_iam_policy.policies[each.value.policy_name].arn) ? aws_iam_policy.policies[each.value.policy_name].arn : each.value.policy_arn
}

# Inline policies for users
resource "aws_iam_user_policy" "inline_user_policies" {
  for_each = var.inline_user_policies

  name   = each.value.name
  user   = aws_iam_user.users[each.value.user_name].name
  policy = jsonencode(each.value.policy)
}

# IAM Groups
resource "aws_iam_group" "groups" {
  for_each = var.groups

  name = each.value.name
  path = each.value.path
}

# Attach policies to groups
resource "aws_iam_group_policy_attachment" "group_policies" {
  for_each = var.group_policy_attachments

  group      = aws_iam_group.groups[each.value.group_name].name
  policy_arn = can(aws_iam_policy.policies[each.value.policy_name].arn) ? aws_iam_policy.policies[each.value.policy_name].arn : each.value.policy_arn
}

# Add users to groups
resource "aws_iam_user_group_membership" "user_group_membership" {
  for_each = var.user_group_memberships

  user   = aws_iam_user.users[each.value.user_name].name
  groups = [for group_name in each.value.group_names : aws_iam_group.groups[group_name].name]
}

# IAM Instance Profiles
resource "aws_iam_instance_profile" "instance_profiles" {
  for_each = var.instance_profiles

  name = each.value.name
  role = aws_iam_role.roles[each.value.role_name].name
}

# IAM Access Keys for users
resource "aws_iam_access_key" "user_keys" {
  for_each = var.user_access_keys

  user = aws_iam_user.users[each.value.user_name].name

  depends_on = [aws_iam_user_policy_attachment.user_policies]
}

# Assume role policy documents for cross-account access
resource "aws_iam_role" "cross_account_roles" {
  for_each = var.cross_account_roles

  name               = each.value.name
  assume_role_policy = jsonencode(each.value.assume_role_policy)
  description        = each.value.description

  tags = merge(
    var.tags,
    {
      Name = each.value.name
    }
  )
}

# Attach policies to cross-account roles
resource "aws_iam_role_policy_attachment" "cross_account_role_policies" {
  for_each = var.cross_account_role_policies

  role       = aws_iam_role.cross_account_roles[each.value.role_name].name
  policy_arn = can(aws_iam_policy.policies[each.value.policy_name].arn) ? aws_iam_policy.policies[each.value.policy_name].arn : each.value.policy_arn
}
