#!/bin/bash

set -e
set -u

PANDA_HOME="$(pwd)/Panda.Meow"

mkdir $PANDA_HOME || exit 1

cd $PANDA_HOME

git clone https://github.com/panda-meow/tail.git
git clone https://github.com/panda-meow/tools.git
git clone https://github.com/panda-meow/content.git
git clone https://github.com/panda-meow/whiskers.git

echo -e "\nsource ~/$PANDA_HOME/tools/pandarc" >> ~/.bashrc
