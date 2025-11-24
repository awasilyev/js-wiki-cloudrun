plugin "aws" {
    enabled = true
    version = "0.40.0"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

plugin "google" {
    enabled = true
    version = "0.34.0"
    source  = "github.com/terraform-linters/tflint-ruleset-google"
}

plugin "terraform" {
  enabled = true
  version = "0.12.0"
  preset  = "recommended"
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}

rule "terraform_unused_declarations" {
  enabled = false
}

rule "terraform_typed_variables" {
  enabled = false
}
