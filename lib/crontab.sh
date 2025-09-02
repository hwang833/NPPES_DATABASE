#!/bin/bash

cd "/home/rbrown/NPPES" || exit 1

source ".venv/bin/activate"

make all > ./lib/NPPES.log 2>&1