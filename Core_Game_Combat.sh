#!/bin/bash

#=================================================================================================================================================================================
# Variables
#=================================================================================================================================================================================
DTE=`date +%Y%m%d-%H%M`
REPBASE=`pwd`
REPAREN=${REPBASE}/ARENE


#=================================================================================================================================================================================
# Programme
#=================================================================================================================================================================================
cd ${REPAREN}
declare -A CHNTAB
declare -A INITAB

for ARENE in `ls -d *`
do
	echo ${ARENE}
	ARNVIC=${ARENE}/vic
	ARNRIP=${ARENE}/rip
	ARNLOG=${ARENE}/log
	FICLOG=${ARNLOG}/${DTE}_${ARENE}_Combat.log

	TOUR=1
	ROUND=1
	INITAB[0 'INI']=0
	INITAB[0 'PNJ']=0
	IDX=0
	CTATT=10	
	echo "==================================================================================" > ${FICLOG}
	echo "| Combat de l'arene : ${ARENE} du ${DTE}" >> ${FICLOG}
	echo "==================================================================================" >> ${FICLOG}
	NBPNJ=`ls ${ARENE}/*.pnj | wc -l`
	TMP=`expr ${NBPNJ} - 1`

	echo "  - Il y a ${NBPNJ} gladiateurs pour le combat dans l'arene : ${ARENE}" >> ${FICLOG}
	for CBT in `ls ${ARENE}/*.pnj`
	do
		. ${CBT}
		CHNTAB[${IDX} 'FIC']=${CBT}
		CHNTAB[${IDX} 'NOM']=${NOM}
		CHNTAB[${IDX} 'FOR']=${FOR}
		CHNTAB[${IDX} 'END']=${END}
		CHNTAB[${IDX} 'VIT']=${VIT}
		CHNTAB[${IDX} 'AGI']=${AGI}
		CHNTAB[${IDX} 'PV']=${PV}
		CHNTAB[${IDX} 'AT']=${AT}
		CHNTAB[${IDX} 'CA']=${CA}
		CHNTAB[${IDX} 'PVact']=${PV}
		CHNTAB[${IDX} 'RIP']=0
		IDX=`expr $IDX + 1`
	done

	for IDX in `seq 0 ${TMP}`
	do
		echo "     Combattant ${IDX} : ${CHNTAB[$IDX 'NOM']} - Caracteristiques : [FOR: ${CHNTAB[$IDX 'FOR']}] [END: ${CHNTAB[$IDX 'END']}] [VIT: ${CHNTAB[$IDX 'VIT']}] [AGI: ${CHNTAB[$IDX 'AGI']}] [PV: ${CHNTAB[$IDX 'PV']}] [AT: ${CHNTAB[$IDX 'AT']}] [CA: ${CHNTAB[$IDX 'CA']}]" >> ${FICLOG}
	done
	echo "" >> ${FICLOG}

	NBDEAD=0
	echo "------------------------------------------------------------------------------------------------------------------------------------------------------" >> ${FICLOG}
	while [ ${NBDEAD} != ${TMP} ]
	do
		echo "- -=[ Tour ${TOUR} ]=- - Calculs des Init" >> ${FICLOG}
		for IDX in `seq 0 ${TMP}`
		do
			TMPINIT=0	
			if [ ${CHNTAB[${IDX} 'RIP']} != 1 ]
			then	
				for i in `seq 1 ${CHNTAB[$IDX 'AGI']}`
				do
					TMPINIT=`expr ${TMPINIT} + $(( RANDOM % 6 + 1))`
				done
			fi
			CHNTAB[${IDX} 'Init']=${TMPINIT}
			echo "  ${CHNTAB[${IDX} 'NOM']} : Init[${CHNTAB[${IDX} 'Init']}]" >> ${FICLOG}
		done
		echo "" >> ${FICLOG}
		TSTRND=0
		for TSTIDX in `seq 0 ${TMP}`
		do
			TSTRND=`expr ${TSTRND} + ${CHNTAB[${TSTIDX} 'Init']}`
		done

		while [ ${TSTRND} != 0 ]
		do
			echo "- -=[ Round ${ROUND} ]=- - Ordre de Passage" >> ${FICLOG}
			for IDX in `seq 0 ${TMP}`
			do
				PLC=0	
				for ORD in `seq ${IDX} -1 0`
				do
					ORT=`expr ${ORD} - 1`
					if [ ${ORD} -eq 0 ]
					then
						if [ ${PLC} != 1 ]
						then
							INITAB[${ORD} 'INI']=${CHNTAB[${IDX} 'Init']}
							INITAB[${ORD} 'PNJ']=${IDX}
							PLC=1
						fi
					else
						if [ ${CHNTAB[${IDX} 'Init']} -gt ${INITAB[${ORT} 'INI']} ]
						then
							Tini=${INITAB[${ORT} 'INI']}
							Tidx=${INITAB[${ORT} 'PNJ']}
							INITAB[${ORT} 'INI']=${CHNTAB[${IDX} 'Init']} 
							INITAB[${ORT} 'PNJ']=${IDX}
							INITAB[${ORD} 'INI']=${Tini}
							INITAB[${ORD} 'PNJ']=${Tidx}
							PLC=1
						else
							if [ ${PLC} != 1 ]
							then
								INITAB[${ORD} 'INI']=${CHNTAB[${IDX} 'Init']} 
								INITAB[${ORD} 'PNJ']=${IDX}
								PLC=1
							fi
						fi
					fi
				done
			done
			for IDX in `seq 0 ${TMP}`
			do
				if [ ${CHNTAB[${INITAB[${IDX} 'PNJ']} 'RIP']} == 1 ]
				then	
					echo "  ${CHNTAB[${INITAB[${IDX} 'PNJ']} 'NOM']} [PV:${CHNTAB[${INITAB[${IDX} 'PNJ']} 'PVact']}/${CHNTAB[${INITAB[${IDX} 'PNJ']} 'PV']}] : [X_Mort_X]" >> ${FICLOG}
				else
					echo "  ${CHNTAB[${INITAB[${IDX} 'PNJ']} 'NOM']} [PV:${CHNTAB[${INITAB[${IDX} 'PNJ']} 'PVact']}/${CHNTAB[${INITAB[${IDX} 'PNJ']} 'PV']}] : Init[${CHNTAB[${INITAB[${IDX} 'PNJ']} 'Init']}]" >> ${FICLOG}
				fi
			done

			for IDXATT in `seq 0 ${TMP}`
			do
				if [ ${CHNTAB[${INITAB[${IDXATT} 'PNJ']} 'RIP']} != 1 ] && [ ${CHNTAB[${INITAB[${IDXATT} 'PNJ']} 'Init']} -gt 0 ]
				then
					IDXDEF=$(( RANDOM % ${TMP} ))
					if [ ${IDXATT} -eq ${IDXDEF} ] || [ ${CHNTAB[${INITAB[${IDXDEF} 'PNJ']} 'RIP']} == 1 ]
					then
						echo "  - ${CHNTAB[${INITAB[${IDXATT} 'PNJ']} 'NOM']} tape dans le vide" >> ${FICLOG}
					else
						SEUIL=25
						JETDETOUCHE=$(( RANDOM % 100 + 1 ))
						if [ ${JETDETOUCHE} -ge ${SEUIL} ]
						then
							DEGAT=0
							NBATT=`expr 1 + ${CHNTAB[${INITAB[${IDXATT} 'PNJ']} 'AT']}`
							for i in `seq 1 ${NBATT}`
							do
								DEGAT=`expr ${DEGAT} + $(( RANDOM % 5 + 1 ))`
							done
							DEGAT=`expr ${DEGAT} +  ${CHNTAB[${INITAB[${IDXATT} 'PNJ']} 'AT']} - ${CHNTAB[${INITAB[${IDXDEF} 'PNJ']} 'CA']}`
							CHNTAB[${INITAB[${IDXDEF} 'PNJ']} 'PVact']=`expr ${CHNTAB[${INITAB[${IDXDEF} 'PNJ']} 'PVact']} - ${DEGAT}`
							echo "  - ${CHNTAB[${INITAB[${IDXATT} 'PNJ']} 'NOM']} attaque ${CHNTAB[${INITAB[${IDXDEF} 'PNJ']} 'NOM']} : l'attaque reussi (${JETDETOUCHE}) et inflige ${DEGAT}" >> ${FICLOG}
							if [ ${CHNTAB[${INITAB[${IDXDEF} 'PNJ']} 'PVact']} -le 0 ]
							then
								echo "  -> ${CHNTAB[${INITAB[${IDXDEF} 'PNJ']} 'NOM']} meurt suite au dernier coup porte" >> ${FICLOG}
								CHNTAB[${INITAB[${IDXDEF} 'PNJ']} 'PVact']=0
								CHNTAB[${INITAB[${IDXDEF} 'PNJ']} 'Init']=0
								CHNTAB[${INITAB[${IDXDEF} 'PNJ']} 'RIP']=1
							fi
						else
							echo "  - ${CHNTAB[${INITAB[${IDXATT} 'PNJ']} 'NOM']} attaque ${CHNTAB[${INITAB[${IDXDEF} 'PNJ']} 'NOM']} : l'attaque echoue (${JETDETOUCHE})" >> ${FICLOG}	
						fi
					fi

					CHNTAB[${INITAB[${IDXATT} 'PNJ']} 'Init']=`expr ${CHNTAB[${INITAB[${IDXATT} 'PNJ']} 'Init']} - ${CTATT}`
					if [ ${CHNTAB[${INITAB[${IDXATT} 'PNJ']} 'Init']} -le 0 ]
					then
						CHNTAB[${INITAB[${IDXATT} 'PNJ']} 'Init']=0
					fi
				fi
			done
			echo "" >> ${FICLOG}

			TSTRND=0	
			for TSTIDX in `seq 0 ${TMP}`
			do
				TSTRND=`expr ${TSTRND} + ${CHNTAB[${TSTIDX} 'Init']}`
			done
			NBDEAD=0
                	for TSTDEAD in `seq 0 ${TMP}`
                	do
                        	NBDEAD=`expr ${NBDEAD} + ${CHNTAB[${TSTDEAD} 'RIP']}`
                	done
			ROUND=`expr ${ROUND} + 1`
		done
		echo "------------------------------------------------------------------------------------------------------------------------------------------------------" >> ${FICLOG}
		ROUND=1
		TOUR=`expr ${TOUR} + 1`
		NBDEAD=0
		for TSTDEAD in `seq 0 ${TMP}`
		do
			NBDEAD=`expr ${NBDEAD} + ${CHNTAB[${TSTDEAD} 'RIP']}`
		done
	done
done
for TSTDEAD in `seq 0 ${TMP}`
do
	if [ ${CHNTAB[${TSTDEAD} 'RIP']} == 1 ]
	then
		mv ./${CHNTAB[${TSTDEAD} 'FIC']} ${ARNRIP}/
	else
		mv ./${CHNTAB[${TSTDEAD} 'FIC']} ${ARNVIC}/
	fi
done
echo "| Fin du Combat de l'arene : ${ARENE} du ${DTE}" >> ${FICLOG}
echo "------------------------------------------------------------------------------------------------------------------------------------------------------" >> ${FICLOG}
