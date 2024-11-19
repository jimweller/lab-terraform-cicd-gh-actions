# Terraform CI/CD with Github Actions, Prototype/Demo

Demonstrates terraform continuous integration and continuous deployment (capital D) using
github actions.

## Pre-requities
* `yor` must be installed
```
brew tap bridgecrewio/tap
brew install bridgecrewio/tap/yor
```
* Two aws accounts, dev and prod
  * DEV is  `AwsProfile` `504400329018`
  * PROD is `AwsProfile`
* An IAM user in each accounts that can create and delete SSM parameters and access the S3 buckets used for state
  * This is using the `@iam_deploy_user` and assuming the `@iam_deploy_role` in each account. They are distinct IAM users per account.
* ACCESS_KEY and ACCESS_SECRET for each user in the respective accounts
  * The keys for `@iac_deploy_user` are in secrets manager in the acounts
* An s3 bucket in each account for tfstate
* The following values stored as github secrets in the repo
  * AWS_DEV_KEY - the AWS_ACCESS_KEY for dev account
  * AWS_DEV_SECRET - the AWS_SECRET_KEY for dev account
  * AWS_DEV_TFSTATE_S3 - the S3 bucket for terraform state for the dev account ( `terraform-remote-state-504400329018-us-east-2`)
  * AWS_DEV_ROLE - the IAM role to assume in the dev account (`arn:aws:iam::201743370211:role/@iac_deploy_role`)
  * AWS_PROD_KEY - the AWS_ACCESS_KEY for prod account
  * AWS_PROD_SECRET - the AWS_SECRET_KEY for prod account
  * AWS_PROD_TFSTATE_S3 - the S3 bucket for terraform state for the prod account (`terraform-remote-state-201743370211-us-east-2`)
  * AWS_PROD_ROLE - the IAM role to assume in the prod account (`arn:aws:iam::504400329018:role/@iac_deploy_role`)

## How it Works
* Automated yor tagging is done locally. This should probably become a precommit hook.
* Any commits pushed to a non-`main` branch will do `terraform` `init`, `validate`, `plan`, and  `apply`  to DEV AWS
* Deleting a non-`main` branch will do `terraform destroy` to DEV AWS.
* Any commits pushed to `main` (merge PR) it does documentation, yor tagging, and  `terraform apply` to PROD AWS. E.g. when a PR is merged into `main`.

## Testing with This Repo
You can try running `scripts/gh-test.sh` which runs through a PR cycle with pauses to look at GH and AWS. Or you can use it as a guide to go through a full PR cycle.

## Testing with a Forked Repo
1. Fork this repo. 
2. Get all your aws resources together
3. Setup the github secrets using those resources
4. If using the same accounts, to avoid collisions
   1. Change the key for the aws backend in ssm_param.tf
   2. Change name of the aws_ssm_parameter in ssm_param.tf
5. Then use the same CLI steps as above

## My local repo is not synced with remote
You probably forgot to do a git pull after yor moved your remote ahead by one commit. You can usually fix this with.

```
git stash
git pull
git stash pop
```

Sometimes it's easier to just backup your local and start with a fresh clone of the remote.


## Caveats
- This repo's branch protection doesn't require reviews. So, you can do solo testing. Otherwise, it is the same as the standards.
- Yor makes changes to TF files during the GH workflow IF they do not already have tags. That can cause some issues in branch protections

## References
- https://nathan.kewley.me/2020-07-21-deploy-to-AWS-using-terraform-and-github-actions/
- https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows
- https://gonzalohirsch.com/blog/semantic-release-and-branch-protection-rules/
