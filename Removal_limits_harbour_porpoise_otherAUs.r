##--------------------------------------------------------------------------------------------------------
## SCRIPT : Threshold for Harbour Porpoises in the Irish Seas and Celtic Sea
##          and West Scotland & Ireland
##
## Authors : Matthieu Authier
## Last update : 2023-01-12
##
## R version 4.2.2 (2022-10-31 ucrt) -- "Innocent and Trusting"
## Copyright (C) 2022 The R Foundation for Statistical Computing
## Platform: x86_64-w64-mingw32/x64 (64-bit)
##--------------------------------------------------------------------------------------------------------

# install the RLA package
# remotes::install_gitlab(host = "gitlab.univ-lr.fr",
#                         repo = "pelaverse/RLA"
#                         )

lapply(c("tidyverse", "rstan", "RLA"),
       library, character.only = TRUE
       )

# "Irish Seas and Celtic Sea"
RLA::PBR(N = 46797, cv = 0.139, Fr = 0.1)

# "West Scotland & Ireland", mPBR = 78
RLA::PBR(N = 44261, cv = 0.139, Fr = 0.1)
