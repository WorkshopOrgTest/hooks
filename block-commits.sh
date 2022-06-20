#!/bin/bash
#
# Reject pushes that contain commits with messages that do not adhere
# to the defined regex.

# This can be a useful pre-receive hook [1] if you want to ensure every
# commit is associated with a ticket ID.
#
# As an example this hook ensures that the commit message contains a
# JIRA issue formatted as [JIRA-<issue number>].
#
# [1] https://help.github.com/en/enterprise/user/articles/working-with-pre-receive-hooks
#

set -e

zero_commit='0000000000000000000000000000000000000000'
msg_regex='[1Q]'

while read -r oldrev newrev refname; do

	# Branch or tag got deleted, ignore the push
    [ "$newrev" = "$zero_commit" ] && continue

    # Calculate range for new branch/updated branch
    [ "$oldrev" = "$zero_commit" ] && range="$newrev" || range="$oldrev..$newrev"

	for commit in $(git rev-list "$range" --not --all); do
		if ! git log --max-count=1 --format=%B $commit | grep -iqE "$msg_regex"; then
			echo "ERROR:"
			echo "ERROR: Your push was rejected because the commit"
			echo "ERROR: $commit in ${refname#refs/heads/}"
			echo "ERROR: Branch Name is not mentioned '1Q'."
			echo "========================================================================"
			echo "Please Follow the below Templates to Write Better Commit Messages"
			echo "========================================================================"
      			echo "1. Separate subject from body with a blank line"
      			echo "2. Limit the subject line to 50 characters"
     			echo "3. Capitalize the subject line"
      			echo "4. Do not end the subject line with a period"
      			echo "5. Use the imperative mood in the subject line"
      			echo "6. Wrap the body at 72 characters"
      			echo "7. Use the body to explain what and why vs. how"
                        echo "========================================================================"
			echo "ERROR: Please fix the commit message and push again."
			echo "ERROR: https://help.github.com/en/articles/changing-a-commit-message"
			echo "ERROR"
			exit 1
		fi
	done

done
