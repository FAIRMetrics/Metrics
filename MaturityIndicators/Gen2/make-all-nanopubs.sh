#!/bin/bash

for I in Gen2_MI_*.md; do O=${I%".md"}; (ruby makenanopubs.rb $I > $O.pre); done

for I in Gen2_MI_*.pre; do O=${I%".pre"}; ./np mktrusty -o $O $I; done

rm *.pre

ls Gen2_MI_* | grep -v .md | awk '{print "cat "$1}' | bash > nanopubs.trig

LASTINDEX=http://purl.org/np/RArp89NoE0geulP2hbChcLYpMs-M1HzY8P3vl-_b3poPE
VERSION=1

./np mkindex \
  -u https://w3id.org/fair/maturity_indicator/np/Gen2/index/ \
  -a https://github.com/FAIRMetrics/Metrics/ \
  -c https://orcid.org/0000-0002-1267-0234 \
  -c https://orcid.org/0000-0001-6960-357X \
  -t "Nanopublications representing the FAIR Maturity Indicators, version $VERSION" \
  -l https://creativecommons.org/publicdomain/zero/1.0/ \
  -x $LASTINDEX \
  -o index \
  nanopubs.trig
