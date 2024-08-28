#!/usr/bin/env bash

apt-get install -y jq

curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y --default-toolchain leanprover/lean4:nightly-2023-01-16

# ~/.elan/bin/elan default leanprover/lean4:nightly

~/.elan/bin/lean --version

apt-get install -y python3 python3-pip python3-dev

cd /autograder/source

AUTOGRADER_REPO=$(jq -r '.autograder_repo' < config.json)

AUTOGRADER_REPO_KEY=$(jq -r '.deploy_token_private_key' < config.json)

if [[ -e ./autograder_deploy_key ]]; then
mkdir -p ~/.ssh
mv autograder_deploy_key ~/.ssh/autograder_deploy_key
chmod 600 ~/.ssh/autograder_deploy_key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/assignments_deploy_key

cp ssh_config ~/.ssh/config


# To prevent host key verification errors at runtime
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts
fi

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
