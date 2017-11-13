#!/bin/bash

set -e
set -u

green() {
  echo -en "\033[0;32m$*\033[0m"
}

yellow() {
  echo -en "\033[0;33m$*\033[0m"
}

red() {
  echo -en "\033[0;31m$*\033[0m"
}

blue() {
  echo -en "\033[0;34m$*\033[0m"
}

bold() {
  echo -en "\033[0;1m$*\033[0m"
}

status() {
  echo -e "$(blue '==>') $(bold $*...)"
}

error() {
  echo -e "$(red 'Error:') $*"
}

PANDA_HOME="$(pwd)/Panda.Meow"

mkdir $PANDA_HOME || {
  error "Panda.Meow is already installed"
  exit 1
}

cd $PANDA_HOME

status "Installing Panda.Meow/tail"
git clone https://github.com/panda-meow/tail.git

status "Installing Panda.Meow/tools"
git clone https://github.com/panda-meow/tools.git

status "Installing Panda.Meow/content"
git clone https://github.com/panda-meow/content.git

status "Installing Panda.Meow/whiskers"
git clone https://github.com/panda-meow/whiskers.git

status "Updating .bashrc" 
echo -e "\nsource $PANDA_HOME/tools/pandarc" >> ~/.bashrc

brew tap | grep -q 'vapor/tap' || { 
  status "Tapping 'vapor/tap'"
  brew tap vapor/homebrew-tap
  status "Updating Homebrew"
  brew update
}

status "Installing Vapor"
brew install vapor
