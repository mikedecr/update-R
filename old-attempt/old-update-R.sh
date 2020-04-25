#!/usr/bin/env bash

# this file will 
# 1. save installed R package names, 
# 2. update R, and then
# 3. reinstall missing packages

# already in directory
# save installed packages, run updateR, quit R
Rscript update-R-01.R

# reopen R
# open -a R.app
r

# run script to install any missing packages
Rscript update-R-02.R


