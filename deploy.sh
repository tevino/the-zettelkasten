#!/bin/bash
set -e

tmp_branch=gh-page

echo ">>>>>> Checking if working directory is clean"
if [[ -n $(git status -s) ]]; then
    echo >&2 "Working directory is not clean"
    exit 1
fi

echo ">>>>>> Checking github remote"
if ! git ls-remote --exit-code github >/dev/null; then
    echo >&2 "A working remote named github is expected to be deployed to"
    exit 2
fi

original_branch="$(git rev-parse --abbrev-ref HEAD)"
original_hash="$(git rev-parse HEAD)"

if git rev-parse --verify "$tmp_branch" >/dev/null; then
    echo ">>>>>> Deleting existing temporary branch $tmp_branch"
    git branch -D "$tmp_branch" >/dev/null
fi
echo ">>>>>> Create a temporary branch $tmp_branch"
git checkout --orphan "$tmp_branch"
echo ">>>>>> Removing $0"
rm -f "$0"
git rm "$0"
echo ">>>>>> Creating the only commit"
git commit -m "deploy $original_hash"
echo ">>>>>> Deploy by push -f to github $tmp_branch"
git push -fu github $tmp_branch
echo ">>>>>> Get back to the original branch $original_branch"
git checkout "$original_branch"
echo ">>>>>> Deleting temporary branch"
git branch -d "$tmp_branch"

echo ">>>>>> Successfully deployed $original_hash"
