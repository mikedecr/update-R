# ----------------------------------------------------
#   R update routine, file 01
#   - Save names of installed packages
#   - Installs new R if applicable
# ----------------------------------------------------

# suppose we have these packages installed
library("here")
library("magrittr")
library("tidyverse")

dir(.libPaths())

# save vector of installed package names
pkgs <- .libPaths() %>%
  dir() %>%
  print() %T>% 
  save(file = here(str_glue("{Sys.Date()}-installed-pkgs.Rdata")))


# install {updateR} if needed
if (("updateR" %in% pkgs) == FALSE) {
  devtools::install_github("AndreaCirilloAC/updateR")
}

setwd("~")
# updateR::updateR() # password goes here

beepr::beep(2)