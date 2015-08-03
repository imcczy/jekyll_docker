#!/bin/bash

WORKDIR=/usr/servers
GITROOT=$WORKDIR/site
WBEROOT=$WORKDIR/html

# Update Git Repo
rm -r $GITROOT
git clone "github page repository HTTPS clone URL" $GITROOT

# Build Site
rm -r $WBEROOT
cd $GITROOT
source /etc/profile.d/rvm.sh
jekyll  build --destination $WBEROOT
