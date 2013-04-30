#!/bin/bash

# First argument ($1): directory containing the configuration file fragments
# Second argument ($2): the path to resulting file

# Remove results of previous runs
rm -f $2

# Concatenate the fragments
for FRAGMENT in `ls $1 | sort -n`; do
        cat $1/$FRAGMENT >> $2
done
