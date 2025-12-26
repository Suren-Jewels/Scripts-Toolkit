resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = var.assume_role_policy

  tags = merge(
    {
      Name = var.role_name
    },
    var.tags
  )
}

resource "aws_iam_policy" "this" {
  count       = var.inline_policy == "" ? 0 : 1
  name        = "${var.role_name}-inline-policy"
  description = "Inline policy for ${var.role_name}"
  policy      = var.inline_policy
}

resource "aws_iam_role_policy_attachment" "managed" {
  count      = length(var.managed_policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = var.managed_policy_arns[count.index]
}

resource "aws_iam_role_policy" "inline" {
  count  = var.inline_policy == "" ? 0 : 1
  name   = "${var.role_name}-inline"
  role   = aws_iam_role.this.id
  policy = var.inline_policy
}
