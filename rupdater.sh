#!/bin/bash
#
# You may run into this issue:
# "-bash: /Users/swvanderlaan/bin/rupdater: /bin/bash: bad interpreter: Operation not permitted"
# Check out https://discussions.apple.com/thread/3733470 for more information.
#
# Typing the following will solve this issue
# xattr -d com.apple.quarantine iCloud/r/rupdater.sh
# xattr -d com.apple.quarantine bin/rupdater
#
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                 R Statistics Updater                             +"
echo "+                                                                                  +"
echo "+ * version:        1.3.3                                                          +"
echo "+ * created by:     Sander W. van der Laan | s.w.vanderlaan-2@umcutrecht.nl        +"
echo "+ * last edited on: 2018-01-24                                                     +"
echo "+                                                                                  +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
say -v Karen "Running 'R Statistics Updater', version 1.3.3. Today is $(date)."
echo ""
echo "* First, updating R..."
## say -v Karen "First, updating R."
Rscript $HOME/iCloud/r/RStats_Updater_v1.r
echo ""
echo "* Now, updating general statistics packages..."
## say -v Samantha "Now, updating general statistics packages."
Rscript $HOME/iCloud/r/Rstats_GENERAL_v1.r
echo ""
echo "* Checking for updates to advanced statistics packages..."
## say -v Samantha "Checking for updates to advanced statistics packages."
Rscript $HOME/iCloud/r/Rstats_ADVANCED_v1.r
echo ""
echo "* Moving on to updating genetics packages..."
## say -v Samantha "Moving on to updating genetics packages."
Rscript $HOME/iCloud/r/Rstats_GENETICS_v1.r
echo "* Also updating additional specific RNA sequence, Omics, and DNA methylation packages..."
## say -v Samantha "Also updating additional specific RNA sequence, omics, and DNA methylation packages."
Rscript $HOME/iCloud/r/Rstats_OMICS_v1.r
echo "* Finally, updating MR-analyses packages..."
## say -v Samantha "Finally, updating MR-analyses packages."
Rscript $HOME/iCloud/r/Rstats_MR_v1.r
echo ""
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Hey mate, I'm all done. Closing off. Have a nice day and a 🍺 . The date is $(date)."
## say -v Karen "Hey mate, I'm all done. Closing off. Have a nice day. The date is $(date)."