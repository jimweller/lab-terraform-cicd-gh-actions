# This simple TF pushes an SSM param to show that something happened in AWS via
# the github action. The value of the environment_type paremeter will be
# determined by the .tfvars files in the env directory.


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.36"
    }
  }

  required_version = "~> 1.5"

  # The bucket is not defined here on purpose. It will vary depending on dev or
  # prod environment. It comes from a github secret that is used on the tf
  # command line in the GH actions.
  backend "s3" {
    key    = "jira-demo-terraform-cicd-gh-actions.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  region = "us-east-2"
}

# This variable is used to change the value of the ssm parameter between dev and
# prod. See the tfvars files in the env/ directory.
variable "environment_type" {
  type        = string
  default     = "nothing"
  description = "This variable is used to change the value of the ssm parameter between dev and prod. See the tfvars files in the env/ directory."
}

# This is the most basic terraform resource, a key and value in the SSM
# parameter store. It is a fast and easy way to test other things like github
# actions and other tooling.
#
# Note, that the tags will be populated by yor. You can delete the whole tags section
# if you want to see it in action.
#
# Note, that the value comes from a variable assigned in the tfvars files in the
# env/ directory
#
# Note that if yor updates tags, then it commits the file in the action. So
# you need to do a git pull after that becase the remote main will be one
# commit ahead of local main. If you change files before git pull, you'll
# have a ball of string to unravel (or start with a fresh git checkout)
resource "aws_ssm_parameter" "environment_type" {
  name        = "environment_type"
  type        = "String"
  value       = var.environment_type
  description = "A basic SSM parameter that will vary between DEV and PROD aws accounts according to the tfvars files in the env/ directory."

  # tags will be injected below  here by yor
  # you can use the tag ChangeMeToTest to force the resource
  # to update. See tf-dev-cicd.yml
  tags = {
    "automation:RetainEBS"     = "No"
    "business:CostCenter"      = "CC5409"
    "business:CustomerName"    = "Hospital Company Inc."
    "business:EnvironmentType" = "Production"
    "business:HsiNumber"       = "54321"
    "business:Platform"        = "Finance"
    "business:Product"         = "Finance:HyCV:HICE"
    git_org                    = "ExampleCoSoftware"
    git_repo                   = "jira-demo-terraform-cicd-gh-actions.git/"
    "security:HIPPA"           = "true"
    "technical:IaC"            = "terraform"
    yor_trace                  = "0045d3da-3862-4adc-9046-a4e6a1415ec8"
  }
}
