#!/bin/bash

## R
# https://linuxize.com/post/how-to-install-r-on-ubuntu-20-04/
sudo apt-get install -y dirmngr gnupg apt-transport-https ca-certificates software-properties-common
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/'
sudo apt-get install -y r-base
# Install some R packages
sudo R -e 'install.packages("knitr")'
sudo R -e 'install.packages("rmarkdown")'

## RStudio
sudo apt-get install -y gdebi-core
wget https://download1.rstudio.org/desktop/bionic/amd64/rstudio-1.3.1093-amd64.deb
sudo gdebi --non-interactive rstudio-1.3.1093-amd64.deb
sudo rm rstudio-1.3.1093-amd64.deb
