#!/bin/bash

REPBASE=`pwd`

for ELT in `ls -d ./ARENE/*`
do
	mv ${ELT}/log/*.log ./
done
