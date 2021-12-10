#!/bin/bash

RESULTFAIL=0

DIRECTORY=$1
INSTRUCTION=$2

TESTCASES="./test_codes/*.txt"

#copy the wanted memory txt file into the main one to be tested and run
if [[ $DIRECTORY == "rtl" && $1 != "help" ]] ; then

	if [[ $INSTRUCTION != "" ]] ; then
	    
	    TEST_CODE="${INSTRUCTION}_*"
	    #echo "code: $TEST_CODE"
	    
	    for i in ${TESTCASES} ; do
	    	RESULTFAIL=0
	    	TESTNAME=$(basename ${i} .txt)
	    	#echo "name: $TESTNAME"
	    
	    	if [[ $TESTNAME == $TEST_CODE ]] ; then
	    	    #echo "found $TESTNAME"
	    		
	    	    cp ./test_codes/$TESTNAME.txt INITIALISED_FILE.txt
		
		    #echo "copying $TESTNAME..."
		    
		    iverilog -g 2012 -Wall -o CPU_testbench ../rtl/mips_cpu/*.v ./CPU_testbench.v ./ram_tiny_CPU.v
		    
		    if [[ $? -ne 0 ]] ; then
			RESULTFAIL=1
		    else

			./CPU_testbench > ./outputs/CPU_testbench_$TESTNAME.stdall
			#to surpress standard error it is redirected #>/dev/null

			PATTERN=" RESULT: "
			NOTHING=""
			# Use "grep" to look only for lines containing PATTERN
			set +e
			grep "${PATTERN}" ./outputs/CPU_testbench_$TESTNAME.stdall > ./outputs/CPU_testbench_$TESTNAME.stdout-lines
			set -e
			# Use "sed" to replace "CPU : OUT   :" with nothing
			sed -e "s/${PATTERN}/${NOTHING}/g" ./outputs/CPU_testbench_$TESTNAME.stdout-lines > ./outputs/CPU_testbench_${TESTNAME}.stdout
  
			
			#echo "comparing ./outputs/CPU_testbench_${TESTNAME}.stdout to ./expected/CPU_testbench_${TESTNAME}_expected.stdout"
			#cmp -s "./outputs/CPU_testbench_${TESTNAME}.stdout" "./expected/CPU_testbench_${TESTNAME}_expected.stdout" 
		        if ! cmp "./outputs/CPU_testbench_${TESTNAME}.stdout" "./expected/CPU_testbench_${TESTNAME}_expected.stdout" > /dev/null 2>&1
		        then
			    RESULTFAIL=2
		        fi
		    fi 
			  

		    if [[ $RESULTFAIL -eq 1 ]] ; then
			echo -e "$TESTNAME\t$INSTRUCTION\t Fail Compilation"
		    elif [[ $RESULTFAIL -eq 2 ]] ; then
		    	if [[ $(cat ./outputs/CPU_testbench_${TESTNAME}.stdout) == "" ]] ; then
		    		echo -e "$TESTNAME\t$INSTRUCTION\t Fail Programm didn't end in the expected nr of cycles."
		    	else
				echo -e "$TESTNAME\t$INSTRUCTION\t Fail Execution: Test return wrong value" $(cat ./outputs/CPU_testbench_${TESTNAME}.stdout) ", should be:" $(cat ./expected/CPU_testbench_${TESTNAME}_expected.stdout)
			fi
		    else 
			echo -e "$TESTNAME\t$INSTRUCTION\t Pass"
		    fi
		    		
		fi
	    done
		
	else
		for i in ${TESTCASES} ; do
		    RESULTFAIL=0
		    TESTNAME=$(basename ${i} .txt)
		    suffix="_*"
		    INSTRUCTION=${TESTNAME%$suffix} #delete suffix from test_code title
		    
		    cp ./test_codes/$TESTNAME.txt ./INITIALISED_FILE.txt
		    #echo "copying $i..."
	    
	    	    iverilog -g 2012 -Wall -o CPU_testbench ../rtl/mips_cpu/*.v ./CPU_testbench.v ./ram_tiny_CPU.v
	    
			
		    if [[ $? -ne 0 ]] ; then
				RESULTFAIL=1
		    else

			./CPU_testbench > ./outputs/CPU_testbench_${TESTNAME}.stdall
			#to surpress standard error it is redirected #>/dev/null
				
			PATTERN=" RESULT: "
			NOTHING=""
			# Use "grep" to look only for lines containing PATTERN
			set +e
			grep "${PATTERN}" ./outputs/CPU_testbench_${TESTNAME}.stdall > ./outputs/CPU_testbench_${TESTNAME}.stdout-lines
			set -e
			# Use "sed" to replace "CPU : OUT   :" with nothing
			sed -e "s/${PATTERN}/${NOTHING}/g" ./outputs/CPU_testbench_${TESTNAME}.stdout-lines > ./outputs/CPU_testbench_${TESTNAME}.stdout
			
			#echo "comparing ./outputs/CPU_testbench_$TESTNAME.stdout to ./expected/CPU_testbench_${TESTNAME}_expected.stdout"
			#cmp -s "./outputs/CPU_testbench_$TESTNAME.stdout" "./expected/CPU_testbench_${TESTNAME}_expected.stdout"

		       	if ! cmp "./outputs/CPU_testbench_${TESTNAME}.stdout" "./expected/CPU_testbench_${TESTNAME}_expected.stdout" > /dev/null 2>&1
		        then
			    RESULTFAIL=2
		        fi
		       
		    fi		
			    

		       if [[ $RESULTFAIL -eq 1 ]] ; then
			echo -e "$TESTNAME\t$INSTRUCTION\t Fail Compilation"
		       elif [[ $RESULTFAIL -eq 2 ]] ; then
			if [[ $(cat ./outputs/CPU_testbench_${TESTNAME}.stdout) == "" ]] ; then
		    		echo -e "$TESTNAME\t$INSTRUCTION\t Fail Programm didn't end in the expected nr of cycles."
		    	else
				echo -e "$TESTNAME\t$INSTRUCTION\t Fail Execution: Test return wrong value" $(cat ./outputs/CPU_testbench_${TESTNAME}.stdout) ", should be:" $(cat ./expected/CPU_testbench_${TESTNAME}_expected.stdout)
			fi
		       else 
			echo -e "$TESTNAME\t$INSTRUCTION\t Pass"
		       fi
		done
	fi

elif [[ $1 == "help" ]] ; then
	
	echo "Valid TEST_CODES: "
	echo ""
	for i in ${TESTCASES} ; do
		TESTNAME=$(basename ${i} .txt)
		echo "${TESTNAME}"
	done
	
else
	echo "ERROR: Required arguments : [Directory] or [Directory] [Instruction]."
fi

