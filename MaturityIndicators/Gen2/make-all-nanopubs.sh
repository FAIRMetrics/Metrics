#!/bin/bash

for I in Gen2_MI_*.md; do O=${I%".md"}; (ruby makenanopubs.rb $I > $O.pre); done

for I in Gen2_MI_*.pre; do O=${I%".pre"}; ./np mktrusty -o $O $I; done

rm *.pre

#ls Gen2_MI_* | grep -v .md | awk '{print "cat "$1}' | bash > nanopubs.trig
