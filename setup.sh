#!/usr/bin/env bash

apt-get install -y jq

curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y --default-toolchain leanprover/lean4:nightly-2023-01-16

# ~/.elan/bin/elan default leanprover/lean4:nightly

~/.elan/bin/lean --version

apt-get install -y python3 python3-pip python3-dev

cd /autograder/source

AUTOGRADER_REPO=$(jq -r '.autograder_repo' < config.json)

echo "looking for: $AUTOGRADER_REPO"

git init 
git remote add origin "https://github.com/$AUTOGRADER_REPO"
git fetch origin 
MAIN_BRANCH=$(git remote show origin | sed -n '/HEAD branch/s/.*: //p')
git reset --hard origin/$MAIN_BRANCH

# ~/.elan/bin/lake update 

~/.elan/bin/lake exe cache get 

# ~/.elan/bin/lake clean

~/.elan/bin/lake build autograder AutograderTests 
