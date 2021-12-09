#!/bin/bash

RESULTFAIL=0

#copy the wanted memory txt file into the main one to be tested and run
if [[ $1 != "" ]] ; then
#   if [[ $1 == "ram_code_byte" ]] ; then
#	cp ../rtl/mips_cpu/CPU_ram/ram_code_byte.txt INITIALISED_FILE.txt
#    elif [[ $1 == "bitwise_logic_byte" ]] ; then
#	cp ../rtl/mips_cpu/CPU_ram/bitwise_logic_byte.txt INITIALISED_FILE.txt
#    elif [[ $1 != NULL ]] ; then
	cp ../rtl/mips_cpu/CPU_ram/$1.txt INITIALISED_FILE.txt
#    fi
	
    echo "copying $1..."
    
    iverilog -g 2012 -Wall -o CPU_testbench ../rtl/mips_cpu/*.v ./ram_tiny_CPU.v
    
    if [[ $? -ne 0 ]] ; then
	RESULTFAIL=1
    else

	./CPU_testbench > ./outputs/CPU_testbench_$1.stdout
	#to surpress standard error it is redirected #>/dev/null

	echo "comparing ./outputs/CPU_testbench_$1.stdout to ./expected/CPU_testbench_$1_expected.stdout"
	cmp -s "./outputs/CPU_testbench_$1.stdout" "./expected/CPU_testbench_$1_expected.stdout"
	    if [[ $? -ne 0 ]] ; then
	            RESULTFAIL=2
	    fi
    fi
	    

    if [[ $RESULTFAIL -eq 1 ]] ; then
	echo "$1, Fail, Compilation"
    elif [[ $RESULTFAIL -eq 2 ]] ; then
	echo "$1, Fail, Execution"
    else 
	echo "$1, Pass"
    fi

else
	TESTCASES="../rtl/mips_cpu/CPU_ram/*_byte.txt"

	for i in ${TESTCASES} ; do
	    RESULTFAIL=0
	    TESTNAME=$(basename ${i} .txt)
	    
		cp ../rtl/mips_cpu/CPU_ram/$TESTNAME.txt ./INITIALISED_FILE.txt
		echo "copying $i..."
    
    		iverilog -g 2012 -Wall -o CPU_testbench ../rtl/mips_cpu/*.v ./ram_tiny_CPU.v
    
		
		    if [[ $? -ne 0 ]] ; then
			RESULTFAIL=1
		    else

			./CPU_testbench > ./outputs/CPU_testbench_${TESTNAME}.stdout
			#to surpress standard error it is redirected #>/dev/null

			echo "comparing ./outputs/CPU_testbench_$TESTNAME.stdout to ./expected/CPU_testbench_${TESTNAME}_expected.stdout"
			cmp -s "./outputs/CPU_testbench_$TESTNAME.stdout" "./expected/CPU_testbench_${TESTNAME}_expected.stdout"

			    if [[ $? -ne 0 ]] ; then
				    RESULTFAIL=2
			    fi
		    fi
			    

		    if [[ $RESULTFAIL -eq 1 ]] ; then
			echo "$TESTNAME, Fail, Compilation"
		    elif [[ $RESULTFAIL -eq 2 ]] ; then
			echo "$TESTNAME, Fail, Execution"
		    else 
			echo "$TESTNAME, Pass"
		    fi
	done
fi
	    
    
