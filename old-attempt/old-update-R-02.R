#----------------------------------------
#   after updating R
#----------------------------------------
# r
where <- "~/Box Sync/r-docs/update/"

# load previous package names
previous <- dir(path = where, pattern = 'installed.Rdata')
(load(file.path(where, previous[length(previous)])))

pkgs


# get currently installed
(current <- dir(.libPaths()))

# check for missing
(not_installed <- pkgs[!pkgs %in% current])


# install any missing
if (identical(not_installed, character(0))) {
  print('Empty')
} else {
  install.packages(not_installed)
}

beepr::beep(5)
