#!/bin/bash
curr_dir=$PWD

for f in "$@";
do
  abs_path=$(readlink -f "$f")
  perl $curr_dir/load_reg_package.pl --path="$abs_path" --exec
done