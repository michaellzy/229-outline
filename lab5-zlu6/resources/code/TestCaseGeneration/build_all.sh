#!/bin/bash
# Test script to test all 6 test cases. lab5.s/build_all.sh must be located
# in ../tests/TeachingStaff. Each test case is run testing everything (edges
# and dominators) and then a diff command is executed on the user input from 
# lab5.s and the expected output. For each test case, the user should see 
# 'Diff passed!'
#
# Written by Daniil Tiganov in Winter 2018

DC='\e[0m'
RED='\e[0;31m'
GREEN='\e[0;32m'

rm -f *.out

echo "Testing 01-odd_series..."
./runTest.sh 0 0 lab5.s tests/TeachingStaff/01-odd_series.bin > 01-odd_series.out
echo "Diffing o1-odd_series.out..."
diff 01-odd_series.out tests/TeachingStaff/01-odd_series.out
if [ $? -ne 0 ]; then 
    echo -e "Diff ${RED}failed${DC}!"
else
    echo -e "Diff ${GREEN}passed${DC}!"
fi

echo "Testing 02-fib..."
./runTest.sh 0 0 lab5.s tests/TeachingStaff/02-fib.bin > 02-fib.out
echo "Diffing 02-fib.out..."
diff 02-fib.out tests/TeachingStaff/02-fib.out
if [ $? -ne 0 ]; then 
    echo -e "Diff ${RED}failed${DC}!"
else
    echo -e "Diff ${GREEN}passed${DC}!"
fi

echo "Testing 03-sum..."
./runTest.sh 0 0 lab5.s tests/TeachingStaff/03-sum.bin > 03-sum.out
echo "Diffing 03-sum.out..."
diff 03-sum.out tests/TeachingStaff/03-sum.out
if [ $? -ne 0 ]; then 
    echo -e "Diff ${RED}failed${DC}!"
else
    echo -e "Diff ${GREEN}passed${DC}!"
fi

echo "Testing 01-colp_branches..."
./runTest.sh 0 0 lab5.s tests/Students/01-colp_branches.bin > 01-colp_branches.out
echo "Diffing 01-colp_branches.out..."
diff 01-colp_branches.out tests/Students/01-colp_branches.out
if [ $? -ne 0 ]; then 
    echo -e "Diff ${RED}failed${DC}!"
else
    echo -e "Diff ${GREEN}passed${DC}!"
fi

echo "Testing 02-colp_deadcode..."
./runTest.sh 0 0 lab5.s tests/Students/02-colp_deadcode.bin > 02-colp_deadcode.out
echo "Diffing 02-colp_deadcode.out..."
diff 02-colp_deadcode.out tests/Students/02-colp_deadcode.out
if [ $? -ne 0 ]; then 
    echo -e "Diff ${RED}failed${DC}!"
else
    echo -e "Diff ${GREEN}passed${DC}!"
fi

echo "Testing 03-colp_oneblock..."
./runTest.sh 0 0 lab5.s tests/Students/03-colp_oneblock.bin > 03-colp_oneblock.out
echo "Diffing 03-colp_oneblock.out..."
diff 03-colp_oneblock.out tests/Students/03-colp_oneblock.out
if [ $? -ne 0 ]; then 
    echo -e "Diff ${RED}failed${DC}!"
else
    echo -e "Diff ${GREEN}passed${DC}!"
fi
