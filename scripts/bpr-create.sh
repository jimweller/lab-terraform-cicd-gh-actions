#!/bin/sh

# create a branch protection rule that follows team git standards

owner=ExampleCoSoftware
repo=jira-demo-terraform-cicd-gh-actions
branch=main

repositoryId="$(gh api graphql -f query='{repository(owner:"'$owner'",name:"'$repo'"){id}}' -q .data.repository.id)"

#
# https://docs.github.com/en/graphql/reference/objects#branchprotectionrule
#
gh api graphql -f query='
mutation($repositoryId:ID!,$branch:String!) {
  createBranchProtectionRule(input: {
    repositoryId: $repositoryId
    pattern: $branch
    allowsDeletions: false
    allowsForcePushes: false
    restrictsPushes: true
    isAdminEnforced: false
    lockBranch: false
    requiresCommitSignatures: true
    requiresApprovingReviews: false
    requiredApprovingReviewCount: 0
    dismissesStaleReviews: true
    requiresConversationResolution: false
    requiresCodeOwnerReviews: false
    requiresLinearHistory: true
    requireLastPushApproval: true
  }) { clientMutationId }
}' -f repositoryId="$repositoryId" -f branch=$branch




