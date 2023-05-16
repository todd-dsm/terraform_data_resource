# terraform_data_resource

a quick experiment to discover the terraform_data resource


During the initial Terraform run, these are the outputs
1) After the initial `tf apply`, these are the results:

```hcl
% tf show
# terraform_data.destination:
resource "terraform_data" "destination" {
    id     = "3dd68e9f-9645-9e22-55aa-485af095b5f9"
    input  = "string_y"
    output = "string_y"
}

# terraform_data.initial:
resource "terraform_data" "initial" {
    id     = "3a6812a0-dcbd-459c-644a-078df814e36e"
    input  = "string_x"
    output = "string_x"
}
```

---

2) On subsequent plans, the initial value (stub) is replaced, but the replacement is not propagated to the destination.

```hcl
% tf plan -var stub='string_new'
...

Terraform will perform the following actions:

  # terraform_data.destination will be replaced due to changes in replace_triggered_by
-/+ resource "terraform_data" "destination" {
      ~ id     = "3dd68e9f-9645-9e22-55aa-485af095b5f9" -> (known after apply)
      ~ output = "string_y" -> (known after apply)
        # (1 unchanged attribute hidden)
    }

  # terraform_data.source will be updated in-place
  ~ resource "terraform_data" "initial" {
        id     = "3a6812a0-dcbd-459c-644a-078df814e36e"
      ~ input  = "string_x" -> "string_new"
      ~ output = "string_x" -> (known after apply)
    }

Plan: 1 to add, 1 to change, 1 to destroy.
```

---

3) Post-apply, the state now looks like this:

```hcl
% tf show
# terraform_data.destination:
resource "terraform_data" "destination" {
    id     = "c8edaf8d-9d9d-b90e-6102-5317ccc20f1d"
    input  = "string_y"
    output = "string_y"
}

# terraform_data.initial:
resource "terraform_data" "initial" {
    id     = "3a6812a0-dcbd-459c-644a-078df814e36e"
    input  = "string_new"
    output = "string_new"
}
```

At the end:
1) The `terraform_data.destination` resource is replaced with a new ID, and
2) `string_x` is updated with `string_new`. 
