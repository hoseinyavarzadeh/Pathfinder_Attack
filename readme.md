# Pathfinder: High-Resolution Control-Flow Attacks Exploiting the Conditional Branch Predictor

Authors:         **Hosein Yavarzadeh**, Archit Agarwal, Max Christman, Christina Garman, Daniel Genkin, Andrew Kwong, Daniel Moghimi, Deian Stefan, Kazem Taram, Dean Tullsen

Source Code:     Hosein Yavarzadeh

Email:          [hyavarzadeh@ucsd.edu](hyavarzadeh@ucsd.edu)

Affiliation:    University of California San Diego (UCSD)

This paper was published at ACM ASPLOS 2024: https://dl.acm.org/doi/10.1145/3620666.3651382 

## System Requirements
Intel 12/13/14th Gen Intel CPUs (P-core)

Note: All the attacks can be extended to previous generations of Intel CPUs, but the code must be adjusted according to the Conditional Branch Predictor (CBP) structure. To know more about this, please refer to our previous papers: https://halfandhalf.cpusec.org/ and https://pathfinder.cpusec.org/

## Step 1: Clone!
To clone the repository and its submodules, use the git clone --recursive command:
```
git clone --recursive https://github.com/hoseinyavarzadeh/pathfinder_source.git
```

## Step 2: Necessary Installations
In order to install required packages and drivers for performance counters run the following commands in the terminal after cloning the github repo. Without Installing the required packages/drivers it will not work. 
```bash
chmod a+x *.sh
./install.sh
```

## Step 3: Let's Run the PHR Attack!
```bash
./run.sh
```

A reasonable result should look like this (with some possible variations). Every digit shows a doublet of the Path History Register (PHR). A doublet is a 2-bit value, and within the PHR, it represents pairs of adjacent bits.
```bash
PHR (lsb to msb): 3 1 1 2 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
```

## How Does This Work?
Within the [PMCTestA.cpp](source/PMCTestA.cpp) file, you'll find a function named "crypto_function" that serves as the victim for PHR reading. This function offers flexibility to accommodate various victim functions for PHR analysis. To observe the PHR results, simply call the desired victim function within this framework. By default, the function demonstrates PHR reading for an empty function.

## Macros for Manipulating PHR/PHT
Within the [attack.nasm](source/attack/attack.nasm) file, you can find macro definitions for clearing and shifting the PHR value. These macro are designed for Alder Lake (and Raptor Lake) architectures and only works in Intel CPUs. Also, you'll see macros for setting the PHR value (named as PHR_Model). In order to do Read/Write PHT entry values you should have a conditional branch with specific PC and the desired PHR value right before the branch.

## PHR Analysis Tool
This can be found in [PHR Analysis Tool Directory](phr-analysis-tool). Pathfinder uses the angr binary analysis tool and an algorithm to identify all potential control flow paths matching the observed PHR values. While it's not guaranteed that there will always be a single path leading to the specific PHR, our extensive analysis has shown that ambiguous results are exceedingly rare due to the PHR’s size and complex update function.

## Optional: Build Intel-IPP Library and Run Read_PHR!
This is only needed if you want to read the PHR (Path History Register) values of Intel-IPP encryption/decryption libraries. 
If you want to call Intel-IPP library function, you should define "INTEL_IPP" at the begining of [PMCTestA.cpp](source/PMCTestA.cpp) file.
```bash
cd ipp-crypto
CC=gcc CXX=g++ cmake CMakeLists.txt -B_build -DARCH=intel64 -DCMAKE_BUILD_TYPE=Debug -DMERGED_BLD:BOOL=ON -DBUILD_EXAMPLES:BOOL=ON
cd _build
make all
```
After Installing the Intel-IPP library, line 48 in [attack.sh](./source/attack/attack.sh) **MUST** be changed according to your library setup!!!

## Citation
```
@inproceedings{yavarzadeh2024pathfinder,
  title={Pathfinder: High-Resolution Control-Flow Attacks Exploiting the Conditional Branch Predictor},
  author={Yavarzadeh, Hosein and Agarwal, Archit and Christman, Max and Garman, Christina and Genkin, Daniel and Kwong, Andrew and Moghimi, Daniel and Stefan, Deian and Taram, Kazem and Tullsen, Dean},
  booktitle={Proceedings of the 29th ACM International Conference on Architectural Support for Programming Languages and Operating Systems, Volume 3},
  pages={770--784},
  year={2024}
}
```

## Acknowldgement
This repository is built upon Anger Fog's excellent [test programs for measuring performance counters](https://agner.org/optimize/#testp).

