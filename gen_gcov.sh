#!/bin/bash

#rm -rf *.gcda *.gcno *.info result
gcc -fprofile-arcs -ftest-coverage $1
if [ $? -eq 0 ]; then
	./a.out
	gcov -a -b -c $1
	rm -rf *.gcno *.gcda
else
	echo compilation error
	exit 1
fi
