#!/bin/bash

set -e
set -u

PANDA_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

mkdir "Panda.Meow" || exit 1

cd Panda.Meow

git clone https://github.com/panda-meow/tail.git
git clone https://github.com/panda-meow/tools.git
git clone https://github.com/panda-meow/content.git
git clone https://github.com/panda-meow/whiskers.git
