#!/bin/bash

gcc -fprofile-arcs -ftest-coverage $1
if [ $? -eq 0 ]; then
	./a.out
	gcov -a -b -c $1
	lcov -d . -o "$1.info" -b . -c --rc lcov_branch_coverage=1
	genhtml --branch-coverage -o result "$1.info"
	rm -rf *.gcda *.gcno *.info
else
	echo compilation error
	exit 1
fi
