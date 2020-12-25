#!/bin/bash

## Cling
wget https://root.cern.ch/download/cling/cling_2020-11-05_ROOT-ubuntu2004.tar.bz2
unar cling_2020-11-05_ROOT-ubuntu2004.tar.bz2 --output-directory /home/$USER/Apps
rm cling_2020-11-05_ROOT-ubuntu2004.tar.bz2
echo "export PATH=/home/\$USER/Apps/cling_2020-11-05_ROOT-ubuntu2004/bin:\$PATH" >> ~/.bashrc
#echo "export PATH=/home/\$USER/Apps/cling_2020-11-05_ROOT-ubuntu2004/bin:\$PATH" >> ~/.bash_profile
#source ~/.bash_profile
