locals {
  # Merge defaults and per-group values to make code cleaner
  node_groups_expanded = { for k, v in var.node_groups : k => merge(
    {
      desired_capacity        = var.workers_group_defaults["asg_desired_capacity"]
      iam_role_arn            = var.default_iam_role_arn
      instance_types          = [var.workers_group_defaults["instance_type"]]
      key_name                = var.workers_group_defaults["key_name"]
      launch_template_id      = var.workers_group_defaults["launch_template_id"]
      launch_template_version = var.workers_group_defaults["launch_template_version"]
      max_capacity            = var.workers_group_defaults["asg_max_size"]
      min_capacity            = var.workers_group_defaults["asg_min_size"]
      subnets                 = var.workers_group_defaults["subnets"]
      taints                  = []
    },
    var.node_groups_defaults,
    v,
  ) if var.create_eks }

  asg_tag_list = flatten([
    for name, info in var.node_groups : [
      [
        for tag in lookup(try(var.node_groups[name], {}), "asg_tags", {}) : {
          group_name = name
          key        = tag.key
          propagate  = try(tag.propagate_at_launch, false)
          value      = tag.value
        }
      ]
    ]
  ])
}
