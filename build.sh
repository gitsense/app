#!/bin/bash

# Exit if any command fails
set -e

app_dir=~/.gitsense-app

if [ -n "$1" ]; then
    app_dir=$1;
fi

if [ -e $app_dir ]; then
    echo "Found existing GitSense App install at ${app_dir}. Please delete this directory and try again." >&2
    exit 1;
fi

gh_token=`cat .gh-token`

rm -rf $app_dir
mkdir $app_dir

git clone --branch beta-1.3.0 https://github.com/gitsense/devboard.git $app_dir

cp boards.json start stop $app_dir
cd $app_dir/packages 

git clone --branch alpha-1.3.0 https://gitsense:$gh_token@github.com/gitsense/docs.git gitsense-docs
git clone --branch msg-0.0.0 https://github.com/gitsense/issues.git gitsense-issues
git clone --branch msg-0.0.0 https://github.com/gitsense/insights.git gitsense-insights
git clone --branch msg-0.0.0 https://github.com/gitsense/pull-requests.git gitsense-pull-requests

npm install 
npm install -g forever
npm run build:widgets
npm run build:boards
npm run bundle
