#!/bin/bash

# https://unix.stackexchange.com/a/189996
apps=(
'wget'
'unar'
'git'
'g++'
'debhelper'
'devscripts'
'gnupg'
'python3'
'python-is-python3'
)

sudo apt-get update

# Loop over apps and install each one with default 'yes' flag
for app in "${apps[@]}"
do
    sudo apt-get install $app -y
done