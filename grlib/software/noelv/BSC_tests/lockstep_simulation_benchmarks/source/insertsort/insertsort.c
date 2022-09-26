/*

  This program is part of the TACLeBench benchmark suite.
  Version V 1.x

  Name: insertsort

  Author: Sung-Soo Lim

  Function: Insertion sort for 10 integer numbers.
     The integer array insertsort_a[  ] is initialized in main function.
     Input-data dependent nested loop with worst-case of
     (n^2)/2 iterations (triangular loop).

  Source: MRTC
          http://www.mrtc.mdh.se/projects/wcet/wcet_bench/insertsort/insertsort.c

  Changes: a brief summary of major functional changes (not formatting)

  License: may be used, modified, and re-distributed freely, but
           the SNU-RT Benchmark Suite must be acknowledged

*/

/*
  This program is derived from the SNU-RT Benchmark Suite for Worst
  Case Timing Analysis by Sung-Soo Lim
*/

#include <stdio.h>
#include <stdint.h>
#include "util.h"
#include "SafeDE_driver.h"



/*
  Forward declaration of functions
*/
void insertsort_initialize( unsigned int *array );
void insertsort_init( void );
int insertsort_return( void );
void insertsort_main( void );
int main( void );

/*
  Declaration of global variables
*/
unsigned int insertsort_a[ 11 ];
int insertsort_iters_i, insertsort_min_i, insertsort_max_i;
int insertsort_iters_a, insertsort_min_a, insertsort_max_a;

volatile unsigned int *shared_flag = (unsigned int*) 0x40900100;
/*
  Initialization- and return-value-related functions
*/

void insertsort_initialize( unsigned int *array )
{

  register volatile int i;
  _Pragma( "loopbound min 10 max 10" )
  for ( i = 0; i < 10; i++ )
    insertsort_a[ i ] = array[ i ];

  insertsort_a[10] = 0;
}


void insertsort_init()
{
  unsigned int a[ 11 ] = {0, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2};

  insertsort_iters_i = 0;
  insertsort_min_i = 100000;
  insertsort_max_i = 0;
  insertsort_iters_a = 0;
  insertsort_min_a = 100000;
  insertsort_max_a = 0;

  insertsort_initialize( a );
}

int insertsort_return()
{
  int i, returnValue = 0;

  _Pragma( "loopbound min 10 max 10" )
  for ( i = 0; i < 10; i++ ){
    returnValue += insertsort_a[ i ];
  }

  return ( returnValue + ( -52 ) ) != 0;
}


/*
  Main functions
*/


void _Pragma( "entrypoint" ) insertsort_main()
{
  int  i, j, temp;
  i = 2;

  insertsort_iters_i = 0;

  _Pragma( "loopbound min 9 max 9" )
  while ( i <= 10 ) {

    insertsort_iters_i++;

    j = i;

    insertsort_iters_a = 0;

    _Pragma( "loopbound min 1 max 9" )
    while ( insertsort_a[ j ] < insertsort_a[ j - 1 ] ) {
      insertsort_iters_a++;

      temp = insertsort_a[ j ];
      insertsort_a[ j ] = insertsort_a[ j - 1 ];
      insertsort_a[ j - 1 ] = temp;
      j--;
    }

    if ( insertsort_iters_a < insertsort_min_a )
      insertsort_min_a = insertsort_iters_a;
    if ( insertsort_iters_a > insertsort_max_a )
      insertsort_max_a = insertsort_iters_a;

    i++;
  }

  if ( insertsort_iters_i < insertsort_min_i )
    insertsort_min_i = insertsort_iters_i;
  if ( insertsort_iters_i > insertsort_max_i )
    insertsort_max_i = insertsort_iters_i;
}

void thread_entry(int cid, int nc)
{
        return;
}


int main(void)
{
    int i;
    int core;

    core = read_csr(mhartid);

    switch (core) {
        case 0: 
            
            printf("\n\n-------------------------- TEST_NAME: INSERTSORT\n\n"); 

            SafeDE_softreset();
            SafeDE_enable();
            //configure max and min slack of lockstep
            SafeDE_min_max_thresholds(5,10);

            *shared_flag = 1;

            SafeDE_start_criticalSec(1);
            //Tacle-bench
            insertsort_init();
            insertsort_main();
            
            SafeDE_finish_criticalSec(1);

            
            printf("\nResult_from_CORE%u:", core+1 ); 
            if ( insertsort_return()  == 0 ) 
                printf(" PASSED\n");
            else
                printf(" FAILED\n");

            *shared_flag = 0;
	    while(1);

            break;

        case 1:

            *shared_flag = 0;

            while (*shared_flag == 0);

            // start lockstep
            SafeDE_start_criticalSec(2);

            insertsort_init();
            insertsort_main();

            SafeDE_finish_criticalSec(2);

            while (*shared_flag == 1);

            printf("\nResult_from_CORE%u:", core+1); 
            if ( insertsort_return()  == 0 ) 
                printf(" PASSED\n");
            else
                printf(" FAILED\n");

            
            SafeDE_report();

            break;

        default:
            while(1);


    }
    return(0);
}
