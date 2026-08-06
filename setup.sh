#!/usr/bin/env bash

apt-get install -y jq

curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh -s -- -y --default-toolchain leanprover/lean4:nightly-2023-01-16

# ~/.elan/bin/elan default leanprover/lean4:nightly

~/.elan/bin/lean --version

apt-get install -y python3 python3-pip python3-dev

# The autograder verifies submissions with Comparator
# (https://github.com/leanprover/comparator), which sandboxes the untrusted
# submission's build using landrun (https://github.com/Zouuup/landrun). Build
# landrun from source and put it on PATH; Comparator falls back to searching
# PATH for it (or COMPARATOR_LANDRUN can point at a specific binary instead).
#
# landrun's go.mod requires Go 1.24+; the `golang-go` apt package on Gradescope's
# Ubuntu 22.04 base image is far too old to build it (and too old to even parse a
# go.mod requiring a version that new), so install a current Go toolchain directly
# from go.dev rather than via apt.
apt-get install -y git
GO_VERSION=$(curl -sSL https://go.dev/VERSION?m=text | head -1)
curl -sSL "https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tar.gz
rm -rf /usr/local/go
tar -C /usr/local -xzf /tmp/go.tar.gz
rm /tmp/go.tar.gz
export PATH="$PATH:/usr/local/go/bin"

git clone https://github.com/Zouuup/landrun /tmp/landrun
(cd /tmp/landrun && go build -o /usr/local/bin/landrun ./cmd/landrun)
rm -rf /tmp/landrun

cd /autograder/source

AUTOGRADER_REPO=$(jq -r '.autograder_repo' < config.json)

if [[ -e ./autograder_deploy_key ]]; then
mkdir -p ~/.ssh
mv autograder_deploy_key ~/.ssh/autograder_deploy_key
chmod 600 ~/.ssh/autograder_deploy_key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/autograder_deploy_key

cp ssh_config ~/.ssh/config


# To prevent host key verification errors at runtime
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts

# In this case we connect via ssh
GIT_URL="git@github.com:"

else 
# in this case we connect via https
GIT_URL="https://github.com/"

fi

echo "looking for: $AUTOGRADER_REPO"

git init 
git remote add origin "$GIT_URL$AUTOGRADER_REPO.git"
git fetch origin 
MAIN_BRANCH=$(git remote show origin | sed -n '/HEAD branch/s/.*: //p')
git reset --hard origin/$MAIN_BRANCH

# ~/.elan/bin/lake update 

~/.elan/bin/lake exe cache get 

# ~/.elan/bin/lake clean

~/.elan/bin/lake build autograder AutograderTests comparator lean4export

