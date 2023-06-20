#!/bin/bash

valoper=$1
jailed_expected=$2
# Check if validator is jailed or not
jailed_actual=$($CHAIN_BINARY q staking validator $valoper --home $HOME_1 -o json | jq -r '.jailed')

echo "Expected jailed status: $jailed_expected, actual status: $jailed_actual"
if [ $jailed_expected != $jailed_actual ]; then
    exit 1
fi
