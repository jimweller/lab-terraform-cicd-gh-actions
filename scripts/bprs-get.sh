#!/bin/sh

owner=ExampleCoSoftware
repo=jira-demo-terraform-cicd-gh-actions

gh api graphql -F owner=${owner} -F repo=${repo} -f query='
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
          allowsDeletions
          allowsForcePushes
          blocksCreations
          dismissesStaleReviews
          isAdminEnforced
          lockAllowsFetchAndMerge
          lockBranch
          pattern
          requireLastPushApproval
          requiredApprovingReviewCount
          requiredDeploymentEnvironments
          requiresApprovingReviews
          requiresCodeOwnerReviews
          requiresCommitSignatures
          requiresConversationResolution
          requiresDeployments
          requiresLinearHistory
          requiresStatusChecks
          requiresStrictStatusChecks
          restrictsPushes
          restrictsReviewDismissals
        }
      }
    }
  }' > demo.json
  
cat demo.json  | jq '.data.repository.branchProtectionRules.nodes[] | del( .matchingRefs , .id )' | sort | uniq > demo.bpr



repo=aws-delivery-org

gh api graphql -F owner=${owner} -F repo=${repo} -f query='
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
          allowsDeletions
          allowsForcePushes
          blocksCreations
          dismissesStaleReviews
          isAdminEnforced
          lockAllowsFetchAndMerge
          lockBranch
          pattern
          requireLastPushApproval
          requiredApprovingReviewCount
          requiredDeploymentEnvironments
          requiresApprovingReviews
          requiresCodeOwnerReviews
          requiresCommitSignatures
          requiresConversationResolution
          requiresDeployments
          requiresLinearHistory
          requiresStatusChecks
          requiresStrictStatusChecks
          restrictsPushes
          restrictsReviewDismissals
        }
      }
    }
  }' > prod.json
  
cat prod.json  | jq '.data.repository.branchProtectionRules.nodes[] | del( .matchingRefs , .id )' | sort | uniq > prod.bpr


echo "demo                                                                    prod"
echo "---------------------------------------------------------------------------------------------------------------"
diff -y *.bpr | grep \|