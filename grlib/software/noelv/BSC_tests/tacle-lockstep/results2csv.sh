#!/bin/bash
# IMPORTANT: Data inside ResultsFolder must correspond to a single execution
# of multi_run.sh
ResultsFolder=results

#Signals as they appear in the report
SignalsCore1="Clock_cycles: Instruction_count_lane_1: Instruction_count_lane_2: Total_instruction_count: Instruction_cache_miss: Data_cache_miss: Branch_predictor_miss:"
SignalsCore2="Instruction_cache_miss: Data_cache_miss: Branch_predictor_miss:"
SignalsLockstep="Cycles_active: Executed_instructions_core1: Executed_instructions_core2: Times_stalled_core1: Times_stalled_core2: Cycles_stalled_core1: Cycles_stalled_core2: Biggest_instruction_difference: Average_instruction_difference: Smallest_instruction_difference:"
TestResults="Result_from_CORE1: Result_from_CORE2:"

#List of results that need to be process
ResultExperimentList=$(ls $ResultsFolder)

for ExperimentFolder in $ResultExperimentList; do
    ResultFiles=$ResultsFolder/$ExperimentFolder

    active_cores=$(grep "TEST_NAME:" -A10 $ResultFiles/binarysearch  | grep -o "NUMBER_OF_CORES:.*" | grep -o ' .*')
    active_cores_p=$'\n'"Number_of_cores:${active_cores}"
    iterations=$(grep "TEST_NAME:" -A10 $ResultFiles/binarysearch  | grep -o "ITERATIONS:.*" | grep -o ' .*')
    iterations_p=$'\n'"Iterations:${iterations}"
    lockstep=$(grep "TEST_NAME" -A10 $ResultFiles/binarysearch  | grep -o "LOCKSTEP:.*" | grep -o ' .*')
    lockstep_p=$'\n'"Lockstep:${lockstep}"
    min_slack=$(grep "TEST_NAME" -A10 $ResultFiles/binarysearch  | grep -o "MIN_SLACK:.*" | grep -o ' .*')
    min_slack_p=$'\n'"Min_slack:${min_slack}"
    max_slack=$(grep "TEST_NAME" -A10 $ResultFiles/binarysearch  | grep -o "MAX_SLACK:.*" | grep -o ' .*')
    max_slack_p=$'\n'"Max_slack:${max_slack}"
    
    # ======================================================================
    # This loop gets the values from CORE 1
    CListValV0=""
    ValV0=$(grep -r "TEST_NAME" -A4 $ResultFiles  | grep -o "TEST_NAME:.*" | grep -o ' .*')

    ListValV0=TEST_NAME
    for f_val in $ValV0; do
        # Iterate the string variable using for loop
        ListValV0="${ListValV0},${f_val}"
    done
    CListValV0="${CListValV0}"$'\n'"${ListValV0}"
    for s_val in $SignalsCore1; do
    
        ListValV0=$s_val
        # for each result file
        ValV0=$(grep -r "Start report CORE 1" -A11 $ResultFiles  | grep -o "$s_val.*" | grep -o ' .*')
    
        for f_val in $ValV0; do
            # Iterate the string variable using for loop
            ListValV0="${ListValV0},${f_val}"
        done
        CListValV0="${CListValV0}"$'\n'"${ListValV0}"
    done



    
    #if [ "$active_cores" -eq "2" ]; then
        # ========================================
        # This loop gets the values from CORE 2
        CListValV1=""
        for s_val in $SignalsCore2; do
        
            ListValV1=$s_val
        
            # for each result file
            ValV1=$(grep -r "Start report CORE 2" -A8 $ResultFiles  | grep -o "$s_val.*" | grep -o ' .*')
        
            for f_val in $ValV1; do
                # Iterate the string variable using for loop
                ListValV1="${ListValV1},${f_val}"
            done
            CListValV1="${CListValV1}"$'\n'"${ListValV1}"
        done
        
        # ========================================
        # This loop gets the values from the Lockstep
        CListValV2=""
        for s_val in $SignalsLockstep; do
        
            ListValV2=$s_val
        
            # for each result file
            ValV2=$(grep -r "SafeDE REPORT:" -A21 $ResultFiles  | grep -o "$s_val.*" | grep -o ' .*')
        
            for f_val in $ValV2; do
                # Iterate the string variable using for loop
                ListValV2="${ListValV2},${f_val}"
            done
            CListValV2="${CListValV2}"$'\n'"${ListValV2}"
        done
        
        # ========================================
        # This loop gets the CCS values for the CORE 0
        CListValV3=""
        for s_val in $TestResults; do
        
            ListValV3=$s_val
        
            # for each result file
            ValV3=$(grep -r "Result_from_CORE" -A5 $ResultFiles  | grep -o "$s_val.*" | grep -o ' .*')
        
            for f_val in $ValV3; do
                # Iterate the string variable using for loop
                ListValV3="${ListValV3},${f_val}"
            done
            CListValV3="${CListValV3}"$'\n'"${ListValV3}"
        done
        
        ## ========================================
        ## This loop gets the CCS values for the CORE 0
        #CListValV4=""
        #for s_val in $SignalCCSX; do
        #
        #    ListValV1=$s_val
        #
        #    # for each result file
        #    ValV1=$(grep -r "Core0 over core1 cotention" -A4 $ResultFiles  | grep -o "$s_val.*" | grep -o ' .*')
        #
        #    for f_val in $ValV1; do
        #        # Iterate the string variable using for loop
        #        ListValV1="${ListValV1},${f_val}"
        #    done
        #    CListValV4="${CListValV4}"$'\n'"${ListValV1}"
        #done
    #fi 
    
    
    benchmark=${1##^.*/}
    
    #get number of iterations
    test_num=$(echo $ListValV0 | grep -o ','| wc -l)
        
    #Output format
    echo $'\n'$'\n'$'\n'
    echo $active_cores_p
    echo $iterations_p
    #if [ "$lockstep" == "YES" ]; then
        echo $lockstep_p
        echo $min_slack_p
        echo $max_slack_p
    #fi
    #echo "$(echo "Test Number,") $(seq -s , $test_num)"
    echo $'\n'CORE0
    echo "${CListValV0}"
    #if [ "$active_cores" -eq "2" ]; then
        echo $'\n'CORE1
        echo "${CListValV1}"
        echo $'\n'LOCKSTEP
        echo "${CListValV2}"
    #fi
    echo $'\n'RESULTS
    echo "${CListValV3}"
    echo ""
done
