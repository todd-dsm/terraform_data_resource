/*
  -------------------------------------------------------|-------------------------------------------------------------
                                         skirting the circular dependency issue
  Problem: 2 resources are built at the same time AND depend on one another, creating the circular dependency issue.

  TEST: the terraform_data is a resource that is used to store data in the terraform state. Whenever the revision variable

  TF Docs:
    * terraform_data: https://developer.hashicorp.com/terraform/language/resources/terraform-data
    * replace_triggered_by: https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle#replace_triggered_by
  -------------------------------------------------------|-------------------------------------------------------------
*/
# This is a workaround for the circular dependency issue.
# The data resource will be replaced whenever the revision variable changes.
# This will cause the example_database resource to be replaced as well.
# The data resource is not used for anything else, so it can be ignored.

# The initial STUB value
# The initial STUB value will be overridden later while passing a new value to the variable during the plan.
variable "stub" {
  type    = string
  default = "string_x"
}

# This block will store the stub string in tf state using the input argument
# so terraform_data can tracks the value of var.stub later, during subsequent plans
resource "terraform_data" "initial" {
  input = var.stub
}

# The new value that will trigger the replacement
locals {
  dynamic_string = "string_y"
}

# The replace_triggered_by monitors terraform_data.source for changes and
# will replace the resource when it changes. This will cause a re-creation of
# this resource.
resource "terraform_data" "destination" {
  input = local.dynamic_string

  lifecycle {
    replace_triggered_by = [
      terraform_data.initial,
    ]
  }
}
