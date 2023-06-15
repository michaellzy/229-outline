# runTest.sh
# Author: Taylor Lloyd
# Date: June 27, 2012
#
# USAGE: ./runTest.sh skipEdges(0/1) skipDominators(0/1) LABFILE TESTFILE
#
# Combines the lab, test, and common execution file,
# then runs the resulting creation. All output generated
# is presented on standard output, after discarding the
# standard SPIM start message, which displays version
# info and could otherwise break tests.

rm -f testBuild.s
cat common.s > testBuild.s
echo ".data" >> testBuild.s
echo -n "skipEdge: .word " >> testBuild.s
echo $1 >> testBuild.s
echo -n "skipDom: .word " >> testBuild.s
echo $2 >> testBuild.s
cat $3 >> testBuild.s
spim -file testBuild.s $4 | sed '1,5d'
