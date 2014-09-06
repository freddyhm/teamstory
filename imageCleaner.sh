#!/bin/sh

for png in `find ./Resources/Assets -name '*.png'`
do
	name=`basename -s .png $png`
	name=`basename -s @2x $name`

	for mfile in `find ./Anypic -name '*.m'` 
	do
		if grep -qi "$name" "$mfile"; then
			invocation=1
		fi
	done

	for mfile in `find . -name '*.m'`
	do 
		if grep -qi "$name" "$mfile"; then
			invocation=1
		fi
	done

	if [ "$invocation" -eq 0 ]; then
		rm "$png"
        echo "$png" + " Deleted"
	fi

	invocation=0
done