# ----------------------------------------------------
#   Installing packages for new R version.
#   Michael DeCrescenzo
# 
#   This script deals with the following problem:
#   You upgrade to new major version of R & want to reinstall packages.
#   However, you don't simply want to get all installed.packages() from CRAN
#     because you may be using an experimental version that is more recent.
#   Or, the pkg isn't on CRAN at all, so you want to obtain from (e.g.) Github
#   
#   This script does the following:
# 
#   1. Save installed package info (name, version, source/github repo)
#   2. Compare local package versions to CRAN 
#      to see if local is ahead of CRAN.
#   3. Do the installing (after updating R)
# 
# ----------------------------------------------------


# you should be working out of some directory for this.
# For me it's ~/tools/update-R

library("here")
library("tidyverse")


# ---- get install source info from installed packages -----------------------


# data frame of all installed packages
local_pkgs <- installed.packages() %>%
  as_tibble() %>%
  print()


# get source details (cran, github...) from package_info()
local_details <- 
  sessioninfo::package_info(pkgs = local_pkgs$Package) %>%
  as_tibble() %>%
  select(package, local_version = ondiskversion, source) %>%
  print()


# you may notice that we have fewer rows now.
# What's in all_pkgs that isn't in locals?
anti_join(local_pkgs, local_details, by = c("Package" = "package"))

# the base packages, which I presume will be fine when updating R.




# ---- compare local pkg versions to CRAN -----------------------


# available.packages() returns pkg info for ALL pkgs on CRAN.
cran_pkgs <- available.packages() %>% 
  as_tibble(.name_repair = tolower) %>%
  print()


# but we only need to compare to what we have locally.
# So we left_join.

# We also determine which package version is more recent.
# Do this using utils::compareVersion().

# Note that if one of the pkg versions is NA, the function infers that 
#   the other version is more recent.

# This means I'm classifying comparisons into a few groups.
# - Local more recent and source contains "Github": 
#     => "Github"
# - Local is more recent, source contains "CRAN", but can't find CRAN version:
#     => "Unavailable on CRAN"
# - Source contains "CRAN" but CRAN version is lower than local?
#     => "Downgraded on CRAN"
# - CRAN is more recent or same as local:
#     => "CRAN"

# last step is to store github repositories for the GH packages.

compare_frame <- 
  left_join(
    x = select(local_details, package, local_version, source),
    y = select(cran_pkgs, package, cran_version = version)
  ) %>%
  group_by(package) %>% 
  mutate(
    source_locale = case_when(
      compareVersion(local_version, cran_version) == 1 &
        str_detect(source, "Github") ~ "Github",
      compareVersion(local_version, cran_version) == 1 &
        is.na(cran_version) &
        str_detect(source, "CRAN") ~ "Unavailable on CRAN",
      compareVersion(local_version, cran_version) == 1 &
        (is.na(cran_version) == FALSE) &
        str_detect(source, "CRAN") ~ "Downgraded on CRAN",
      compareVersion(local_version, cran_version) %in% c(-1, 0) ~ "CRAN"
    ),
    github_repo = case_when(
      source_locale == "Github" ~ 
        str_split(string = source, pattern = "@", simplify = TRUE)[,1] %>%
        str_replace("Github \\(", ""),
      TRUE ~ as.character(NA)
    ),
  ) %>%
  ungroup() %>%
  print(n = nrow(.))


# see how many packages don't record CRAN as the future install source
compare_frame %>%
  filter(source_locale != "CRAN") %>%
  arrange(source_locale)

# In my case...
# - StanHeaders got its version downgraded, see <https://github.com/cran/StanHeaders/commit/2294a66cb1876568b6af74a6c4a1233bf6b6e00f>
# - Can't get CRAN info for Zelig or foreign.
# - Rest are Github packages



# ---- save pkg info when satisfied -----------------------

# data location
dir.create(here("data"))

out_file <- as.character(str_glue("pkg-data_{Sys.Date()}.rds"))

write_rds(compare_frame, here("data", out_file))




# ---- this is where you would install new R ------------------

# https://cran.r-project.org/



# ---- reinstall -----------------------

# we need package to install from github
install.packages("remotes")

# should still be operating in your working directory
# so if you want to use {here}, you can.
install.packages("here")

# read package data
pkgs <- readRDS(here::here("data", "pkg-data_2020-04-25.rds"))

head(pkgs)


# install from cran
# using vector of package names
cran_pkgs <- pkgs[pkgs$source_locale != "Github", ][["package"]]

# probably should have excluded rstan tbh.
# I feel like I'm going to regret not taking special care for that one.
install.packages(cran_pkgs)


# install from github
# using vector of github repositories
github_pkgs <- 
  pkgs[pkgs$source_locale == "Github", ][["github_repo"]]

remotes::install_github(github_pkgs)





