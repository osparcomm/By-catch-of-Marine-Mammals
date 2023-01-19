##--------------------------------------------------------------------------------------------------------
## SCRIPT : Threshold for Harbour Porpoises in the North Sea
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

### load life history parameters for the Harbour Porpoise in the North Sea
data("north_sea_hp")
str(north_sea_hp$life_history)

### for stan: parallelization
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

## load Stan models
data(rlastan_models)
# use uniform priors
cat(rlastan_models$uniform)
# compile RLA model
rlastan <- rstan::stan_model(model_code = rlastan_models$uniform,
                             model_name = "RLA"
                             )
## prepare by-catch and abundance data on the harbour porpoise in the North Sea
rlalist <- list(survey = data.frame(mean = north_sea_hp$SCANS$N_hat,
                                    cv = north_sea_hp$SCANS$CVs,
                                    # indicator variable of when the SCANS
                                    # survey took place. 2016 is 51
                                    scans = c(29, 40, 51)
                                    ),
                removals = north_sea_hp$bycatch$mean
                )

## fit the RLA
mod <- rlafit(rlalist = rlalist,
              rlastan = rlastan,
              distribution = "truncnorm",
              n_chains = 4,
              n_iter = 2.2e4,
              n_warm = 2e3,
              model = "cooke",
              # get the complete stan output
              everything = TRUE
              )

## check convergence with Rhat
plot(mod,
     plotfun = 'rhat',
     pars = c("removal_limit", "depletion", "K", "r", "abundance")
     )

## have a look at the trace of parameters
traceplot(mod,
          pars = c("depletion", "r"),
          inc_warmup = TRUE
          )

## have a look at the posterior marginals
plot(mod,
     plotfun = 'hist',
     pars = c("depletion", "r", "removal_limit")
     )

## look at the posterior geometry of the two unknown parameters
pairs(mod,
      pars = c("depletion", "r")
      )

## summarizes the posterior
print(mod,
      pars = c("removal_limit", "depletion", "K", "r", "abundance"),
      digits = 3
      )

## compute the threshold as a quantile of the posterior distribution
rstan::extract(mod, "removal_limit")$removal_limit %>%
  quantile(prob = 0.30) * last(north_sea_hp$SCANS$N_hat) %>%
  round()

### expect some variations in the outcome because of sampling variation.
# The limit is hovering around 1622
