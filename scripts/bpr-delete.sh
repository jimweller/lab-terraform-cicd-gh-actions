#!/bin/sh

owner=ExampleCoSoftware
repo=jira-demo-terraform-cicd-gh-actions

#repositoryId="$(gh api graphql -f query='{repository(owner:"'$owner'",name:"'$repo'"){id}}' -q .data.repository.id)"


ruleid=$(gh api graphql -F owner=${owner} -F repo=${repo} -f query='
  query ($owner: String!, $repo: String!) {
    repository(owner: $owner, name: $repo) {
      branchProtectionRules(first: 100) {
        nodes {
          matchingRefs(first: 100) {
            nodes {
              name
            }
          }
          id
        }
      }
    }
  }' -q  '.data.repository.branchProtectionRules.nodes.[].id')


gh api graphql -F ruleid=$ruleid -f query='
mutation( $ruleid: ID!) {
  deleteBranchProtectionRule(input:{
    branchProtectionRuleId: $ruleid }) {
    clientMutationId
    }
}'

