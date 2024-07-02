# *****************************************
# CONFIDENTIAL SOURCE CODE, DO NOT DISTRIBUTE!
# IN SUBMISSION, ASPLOS 2024.
# *****************************************
#     Project:        PathFinder, PHR Attack Proof-of-Concept (PoC)
#     Author:         Hosein Yavarzadeh
#     Email:          hyavarzadeh@ucsd.edu
#     Affiliation:    University of California, San Diego (UCSD)
# *****************************************
#!/bin/bash
# install.sh -- (c) Copyright 2023 by Hosein Yavarzadeh.

# make all scripts executable
find . -type f -name "*.sh" -exec chmod a+x {} +

# Necessary installations
sudo apt-get install g++-multilib
sudo apt-get install nasm

# Driver installations
cd ./driver-linux
chmod a+x *.sh
make
sudo ./install.sh

# Initilaizations
cd ../source
chmod a+x *.sh
./init.sh
