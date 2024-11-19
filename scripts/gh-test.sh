#!/bin/sh

# This script will perform a full PR workflow on this repository. It will update
# the ChangeMeToTest tag in the ssm_param.tf file, create a new branch, a new
# pull reqeust and merge to main.

the_serial=$(date +%s)
the_date=`date`

# What type of change?
# 
# https://www.npmjs.com/package/conventional-changelog-eslint
MY_TYP="fix"

# an optional prefix to add to all messaging
MY_PREFIX="jira-123"

# branch name
MY_BRANCH="$MY_TYP/$MY_PREFIX-branch-$the_serial"

# commit message
MY_CMSG="$MY_TYP: $MY_PREFIX commit message $the_serial"

# PR title
MY_TITLE="$MY_TYP: $MY_PREFIX PR title $the_serial"

#PR body
MY_BODY="$MY_PREFIX Hello world. PR body $the_serial"

echo "-----------------------------------------------------------------------------"
echo "Below is the config for this PR cycle run, in case you need the strings.   --"
echo "If you want the yor tags refreshed, delete tags{} from ssm_parm.tf         --"
echo "Then, press ENTER  .                                                       --"
echo "-----------------------------------------------------------------------------"
set | grep MY_
read 


echo "-- CREATING A BRANCH"
echo "-----------------------------------------------------------------------------"
git checkout -b "$MY_BRANCH"

echo "-- PUSHING NEW BRANCH TO ORIGIN"
echo "-----------------------------------------------------------------------------"
git push --set-upstream origin $MY_BRANCH


echo "-- TAGGING WITH YOR"
echo "-----------------------------------------------------------------------------"
yor tag -d . --config-file .tag_config.yml -t git_org -t git_repo -t yor_trace -i Terraform


echo "-- RUNNING SOME INTERMEDIATE NON-SEMANTIC COMMITS, LIKE DEVS DO"
echo "-----------------------------------------------------------------------------"

# these are some intermediate commits to show squash merging and semantic release
# they do not follow standards which is allowed before squashing accoring to team rules
for ((i=1;i<=3;i++))
do
    s=`date +%s`
    echo $s > change-me.txt && git add --verbose . && git commit --message "non-conventional commit $s"
    sleep 1
done

date >> change-me.txt


echo "-- COMMITING WITH A SEMANTIC COMMIT MESSAGE"
echo "-----------------------------------------------------------------------------"
git add --verbose .
git commit --message "$MY_CMSG"


echo "-- PUSHING BRANCH'S COMMITS TO ORIGIN"
echo "-----------------------------------------------------------------------------"
git push --set-upstream origin $MY_BRANCH


echo "-- CREATING PULL REQUEST ON GITHUB FOR THE NEW BRANCH"
echo "-----------------------------------------------------------------------------"
gh pr create --title "$MY_TITLE" --body="$MY_BODY" 


echo
echo
echo "-----------------------------------------------------------------------------"
echo "Wait for the DEV Terraform CI/CD Pipeline job to complete in GH actions.   --"
echo "Examine the new branch and new PR while you are there.                     --"
echo "Then, press ENTER  .                                                       --"
echo "-----------------------------------------------------------------------------"
echo
read 


echo "-- MERGING THE PULL REQUEST ON GITHUB"
echo "-----------------------------------------------------------------------------"
gh pr merge "$MY_BRANCH" -s


echo
echo
echo "-----------------------------------------------------------------------------"
echo "Go watch the DEV Terraform CI/CD Cleanup and PROD Terraform CI/CD Pipeline --"
echo "jobs run in GH actions. Then go check AWS for the new SSM parameters       --"
echo "Then, press ENTER  .                                                       --"
echo "-----------------------------------------------------------------------------"
read

echo
echo

echo "-- SWITCHING TO THE main BRANCH"
echo "-----------------------------------------------------------------------------"
git checkout main


echo "-- DELETING THE LOCAL BRANCH"
echo "-----------------------------------------------------------------------------"
git branch  --delete "$MY_BRANCH"


echo "-- PULLING main FROM ORIGIN SINCE IT NOW DIVERGES FROM LOCAL"
echo "-----------------------------------------------------------------------------"
git pull


echo "-- ALL DONE. BYE."
echo "-----------------------------------------------------------------------------"

