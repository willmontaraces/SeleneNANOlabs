/*

  This program is part of the TACLeBench benchmark suite.
  Version V 1.9

  Name: cosf

  Author: Dustin Green

  Function: cosf performs calculations of the cosinus function

  Source: 

  Original name:

  Changes:

  License: this code is FREE with no restrictions

*/

#include "init_functions.c"
#include "wcclibm.h"


/*
  Forward declaration of functions
*/

void cosf_init( void );
void cosf_main( void );
int cosf_return( void );
int main( void );


/*
  Declaration of global variables
*/

float cosf_solutions;


/*
  Initialization function
*/

void __attribute__ ((noinline)) cosf_init( void )
{
  cosf_solutions = 0.0f;
}


/*
  Return function
*/

int cosf_return( void )
{
  int temp = cosf_solutions;

  if ( temp == -4 )
    return 0;
  else
    return -1;
}


/*
  Main functions
*/

void __attribute__ ((noinline)) cosf_main( void )
{
  float i;
  _Pragma( "loopbound min 100 max 100" )
  for ( i = 0.0f; i < 10; i += 0.1f )
    cosf_solutions += basicmath___cosf( i );
}



int main(void)
{
    int i;

    switch (__CORE__) {
        case 1: 
            
            printf("\n\n-------------------------- TEST_NAME: COSF\n\n"); 

            init_test_core1();

            //Tacle-bench
            for (i=0 ; i<__ITERATIONS__ ; i++){
                cosf_init();
                cosf_main();
            }

            end_test_core1();
            
            printf("\nResult_from_CORE%u:", __CORE__); 
            if ( cosf_return()  == 0 ) 
                printf(" PASSED\n");
            else
                printf(" FAILED\n");

            printf("Result_from_CORE2:");
            if ( *shared_result  == 0 )
                printf(" PASSED\n");
            else
                printf(" FAILED\n");

            break;

        case 2:

            init_test_core2();
            
            for (i=0 ; i<__ITERATIONS__ ; i++){
                cosf_init();
                cosf_main();
            }

            end_test_core2();


            *shared_result = cosf_return();
            while(1);
            break;

    }
    return(0);
}

