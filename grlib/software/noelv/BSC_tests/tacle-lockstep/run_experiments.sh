#!/bin/bash

#syntax:
#./run_experiments.sh iterations active_cores lokcstep min_slack max_slack 

# iterations:   number of execution of each test 
# active_cores: 1 or 2 cores executing the tacle-benches
# lockstep:     1 to use lockstep, 0 not to use it
# min_slack:    minimum slack in the lockstep
# max_slack:    maximum slack in the lockstep


results_folder=results
csv_results_folder=csv_results
grmon_folder=grmon_scripts

date=`date +%Y_%m_%d_%I_%M`

iterations=$1
iterations_default=750

active_cores=$2
active_cores_default=2

lockstep=$3

min_slack=$4
min_slack_default=20

max_slack=$5
max_slack_default=1000

#Each iteration (for slack_iterations iterations) the minimum and maximum slacks are incremented and decremented by slack_step respectively
slack_step=0
slack_iterations=1


if [ -z "$lockstep" ] 
then
    lockstep=0
    min_slack=0
    max_slack=0
fi




if [ -z "$iterations" ]; then
    #Creates results folder it the do not exits and clean results folder
    mkdir -p $results_folder
    mkdir -p $csv_results_folder
    rm -r $results_folder/*

    #########################################################################################################################
    #EXPERIMENT: single core 
    echo "EXPERIMENT: single core"
    results_name=1_single_core
    iterations=$iterations_default
    active_cores=1
    lockstep=0
    min_slack=0
    max_slack=0

    #make a directory to save the tests results
    mkdir -p $results_folder/$results_name
    #cleans previous binaries
    make clean
    
    echo "iterations=$iterations active_cores=$active_cores lockstep=$lockstep min_slack=$min_slack max_slack=$max_slack" 
    #compiles all the tacle-benches
    for MULTICORE_BENCHMARK in $(ls source); do
        make $MULTICORE_BENCHMARK.riscv iterations=$iterations active_cores=$active_cores lockstep=$lockstep min_slack=$min_slack max_slack=$max_slack 
    done

    #depending of the number of active cores, a different grmon script will be executed
    grmon_script=$grmon_folder/active_cores_2.grmon

    #executes all the tacle-benches
    for MULTICORE_BENCHMARK in $(ls source); do
        test_name=$MULTICORE_BENCHMARK
        export MULTICORE_BENCHMARK
        grmon -digilent -u -v -jtagcable 2 -log $results_folder/$results_name/$test_name -c $grmon_script
    done

    #cleans binaries
    make clean
    #########################################################################################################################

    #########################################################################################################################
    #EXPERIMENT: 2 cores, no lockstep (uncontrolled diversity)  
    echo "EXPERIMENT: 2 cores, no lockstep (uncontrolled diversity)"
    results_name=2_uncontrolled_diversity
    iterations=$iterations_default
    active_cores=2
    lockstep=0
    min_slack=0
    max_slack=0

    #make a directory to save the tests results
    mkdir -p $results_folder/$results_name
    #cleans previous binaries
    make clean
    
    echo "iterations=$iterations active_cores=$active_cores lockstep=$lockstep min_slack=$min_slack max_slack=$max_slack" 
    #compiles all the tacle-benches
    for MULTICORE_BENCHMARK in $(ls source); do
        make $MULTICORE_BENCHMARK.riscv iterations=$iterations active_cores=$active_cores lockstep=$lockstep min_slack=$min_slack max_slack=$max_slack 
    done

    #depending of the number of active cores, a different grmon script will be executed
    grmon_script=$grmon_folder/active_cores_$active_cores.grmon

    #executes all the tacle-benches
    for MULTICORE_BENCHMARK in $(ls source); do
        test_name=$MULTICORE_BENCHMARK
        export MULTICORE_BENCHMARK
        grmon -digilent -u -v -jtagcable 2 -log $results_folder/$results_name/$test_name -c $grmon_script
    done

    #cleans binaries
    make clean

    #########################################################################################################################

    #########################################################################################################################
    #EXPERIMENT: 2 cores, lockstep (controlled diversity), differente slack configurations 
    echo "EXPERIMENT: 2 cores, lockstep (controlled diversity), different slack configurations"  
    for (( i=0; i<$slack_iterations; i++ ))
    do
        let slack_difference=$i*$slack_step
        let max_slack_test=$max_slack_default+$slack_difference
        min_slack_test=$min_slack_default
        echo min slack: $min_slack_test
        echo max slack: $max_slack_test
        results_name=controlled_diversity__$min_slack_test-$max_slack_test
        iterations=$iterations_default
        active_cores=2
        lockstep=1
        min_slack=$min_slack_test
        max_slack=$max_slack_test

        # make a directory to save the test results
        mkdir -p $results_folder/$results_name
        #cleans previous binaries
        make clean
        
        echo "iterations=$iterations active_cores=$active_cores lockstep=$lockstep min_slack=$min_slack max_slack=$max_slack" 
        #compiles all the tacle-benches
        for MULTICORE_BENCHMARK in $(ls source); do
            make $MULTICORE_BENCHMARK.riscv iterations=$iterations active_cores=$active_cores lockstep=$lockstep min_slack=$min_slack max_slack=$max_slack 
        done

        #depending of the number of active cores, a different grmon script will be executed
        grmon_script=$grmon_folder/active_cores_$active_cores.grmon

        #executes all the tacle-benches
        for MULTICORE_BENCHMARK in $(ls source); do
            test_name=$MULTICORE_BENCHMARK
            export MULTICORE_BENCHMARK
            grmon -digilent -u -v -jtagcable 2 -log $results_folder/$results_name/$test_name -c $grmon_script
        done

        #cleans binaries
        make clean
    done
    #########################################################################################################################

    #translate results to csv
    ./results2csv.sh > csv_results/all_tests--$date.csv

else
    #Creates results folder it the do not exits and clean results folder
    mkdir -p $results_folder
    mkdir -p $csv_results_folder
    rm -r $results_folder/*

    #cleans previous binaries
    make clean
    
    echo "iterations=$iterations active_cores=$active_cores lockstep=$lockstep min_slack=$min_slack max_slack=$max_slack" 
    experiment_name=cores-$active_cores--iterations-$iterations--lockstep-$lockstep--min_slack-$min_slack--max_slack-$max_slack 
    results_name=$experiment_name--$date
    mkdir -p $results_folder/$results_name

    #compiles all the tacle-benches
    for MULTICORE_BENCHMARK in $(ls source); do
        make $MULTICORE_BENCHMARK.riscv iterations=$iterations active_cores=$active_cores lockstep=$lockstep min_slack=$min_slack max_slack=$max_slack 
    done
        
        #depending of the number of active cores, a different grmon script will be executed
        grmon_script=$grmon_folder/active_cores_$active_cores.grmon

    #executes all the tacle-benches
    for MULTICORE_BENCHMARK in $(ls source); do
        test_name=$MULTICORE_BENCHMARK
        export MULTICORE_BENCHMARK
        grmon -digilent -u -v -jtagcable 2 -log $results_folder/$results_name/$test_name -c $grmon_script
    done

    #cleans binaries
    make clean

    #translate results to csv
    ./results2csv.sh > csv_results/$results_name.csv

fi
