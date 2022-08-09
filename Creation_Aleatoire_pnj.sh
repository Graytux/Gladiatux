#!/bin/bash

REPBASE=`pwd`
REPAREN=${REPBASE}/ARENE

ROLL=5

for ChnR in `< /dev/urandom tr -dc 'A-Z-a-z-0-9'| fold -w10 | head -$ROLL`
do
	echo "NOM=${ChnR}" > ${REPAREN}/${ChnR}.pnj
	END=$(( RANDOM % 5 + 1 ))
	VIT=$(( RANDOM % 5 + 1 ))
	AGI=$(( RANDOM % 5 + 1 ))
	FOR=$(( RANDOM % 5 + 1 ))
	PV=$(( ${VIT} * 5 ))
	CA=$(( ${END} / 5 ))
	AT=$(( ${FOR} / 5 ))
	echo "END=${END}" >> ${REPAREN}/${ChnR}.pnj
	echo "VIT=${VIT}" >> ${REPAREN}/${ChnR}.pnj
	echo "AGI=${AGI}" >> ${REPAREN}/${ChnR}.pnj
	echo "FOR=${FOR}" >> ${REPAREN}/${ChnR}.pnj
	echo "PV=${PV}" >> ${REPAREN}/${ChnR}.pnj
	echo "CA=${CA}" >> ${REPAREN}/${ChnR}.pnj
	echo "AT=${AT}" >> ${REPAREN}/${ChnR}.pnj
done
