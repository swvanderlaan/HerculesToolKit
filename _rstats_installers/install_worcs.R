# Install WORCS

if(!requireNamespace("remotes"))install.packages("remotes")
remotes::install_github("cjvanlissa/worcs", dependencies = TRUE, update = "never")
tinytex::install_tinytex()
worcs::git_user("swvanderlaan", "s.w.vanderlaan@gmail.com", overwrite = TRUE)

install.packages("RcppArmadillo")

remotes::install_github("crsh/papaja", dependencies = TRUE, update = "never")

