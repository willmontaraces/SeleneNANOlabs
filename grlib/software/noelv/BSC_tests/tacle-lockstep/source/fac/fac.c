/*

  This program is part of the TACLeBench benchmark suite.
  Version V 1.x

  Name: fac

  Author: unknown

  Function: fac is a program to calculate factorials.
    This program computes the sum of the factorials
    from zero to five.

  Source: MRTC
          http://www.mrtc.mdh.se/projects/wcet/wcet_bench/fac/fac.c

  Changes: CS 2006/05/19: Changed loop bound from constant to variable.

  License: public domain

*/

#include "init_functions.c"
/*
  Forward declaration of functions
*/
int printf(const char * restrict format, ... );
int fac_fac( int n );
void fac_init();
int fac_return();
void fac_main();
int main( void );
int counter1 = 0;
/*
  Declaration of global variables
*/

int fac_s;
volatile int fac_n;


/*
  Initialization- and return-value-related functions
*/


void __attribute__ ((noinline)) fac_init()
{
  fac_s = 0;
  fac_n = 5;
}


int __attribute__ ((noinline)) fac_return()
{
  int expected_result = 154;
  return fac_s - expected_result;
}


/*
  Arithmetic math functions
*/


int fac_fac ( int n )
{
    counter1++;
  if ( n == 0 )
    return 1;
  else
    return ( n * fac_fac ( n - 1 ) );
}


/*
  Main functions
*/


void __attribute__ ((noinline)) fac_main ()
{
  int i;

  _Pragma( "loopbound min 6 max 6" )
  for ( i = 0;  i <= fac_n; i++ ) {
    _Pragma( "marker recursivecall" )
    fac_s += fac_fac ( i );
    _Pragma( "flowrestriction 1*fac_fac <= 6*recursivecall" )
  }
}



int main(void)
{
    int i;

    switch (__CORE__) {
        case 1: 
            
            printf("\n\n-------------------------- TEST_NAME: FAC\n\n"); 

            init_test_core1();

            //Tacle-bench
            for (i=0 ; i<__ITERATIONS__ ; i++){
                fac_init();
                fac_main();
            }

            end_test_core1();
            
            printf("\nResult_from_CORE%u:", __CORE__); 
            if ( fac_return()  == 0 ) 
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
                fac_init();
                fac_main();
            }

            end_test_core2();


            *shared_result = fac_return();
            while(1);
            break;

    }
    return(0);
}
