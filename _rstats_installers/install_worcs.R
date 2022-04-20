################################################################################
###                        SCRIPT to install WORCS                           ###
################################################################################

# https://github.com/cjvanlissa/worcs

if(!requireNamespace("remotes"))
  install.packages("remotes")

remotes::install_github("cjvanlissa/worcs", dependencies = TRUE, update = "never")

tinytex::install_tinytex()

worcs::git_user("Sander W. van der Laan", "s.w.vanderlaan@gmail.com", overwrite = TRUE)

remotes::install_github("crsh/papaja", dependencies = TRUE, update = "never")
