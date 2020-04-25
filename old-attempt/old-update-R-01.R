#----------------------------------------
#   1. Saves vector of installed package names
#   2. Checks for new R and installs
#----------------------------------------

where <- "~/Box Sync/r-docs/update/"


# save currently installed package names
(pkgs <- dir(.libPaths()))

save(pkgs, file = paste0(where, Sys.Date(), '-installed.Rdata'))

list.files(where)


#----------------------------------------
#   New R version
#----------------------------------------
install.packages("devtools", repos = "https://cloud.r-project.org")
devtools::install_github("AndreaCirilloAC/updateR")

library("updateR")
# updateR::updateR() # password goes here

beepr::beep(5)

q()
