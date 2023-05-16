#!/bin/bash
# Qoutes: "Your face, your ass - what's the difference?", "Now you see me, now you’re dead.", "Your ass is grass, and I’ve got the weed whacker.",  "You're an inspiration for birth control.",  "My boot, your face; the perfect couple.",  "I’m an equal opportunity ass kicker",  "Little pig, little pig let me in. Or I'll huff and I'll puff and I'll kick your ass in!",  "I've got balls of steel.",  "Hail to the king, baby!", "It’s time to kick ass and chew bubble gum...and I’m all outta gum. "
for S in "Hail to the king, baby!", "It’s time to kick ass and chew bubble gum...and I’m all outta gum. ", "Your face, your ass - what's the difference?" ; do 
	# Generate the random number 
	# https://linuxhint.com/generate-random-number-bash/
	randomNumber=$((60 + $RANDOM % 3600))
	#echo $randomNumber
	say -v Whisper $S 
	sleep $randomNumber
done

#say -v Rocko "Isn't it great that your Mac can speak to you?"