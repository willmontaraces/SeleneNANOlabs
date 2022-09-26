/*

  This program is part of the TACLeBench benchmark suite.
  Version V 1.9

  Name: rad2deg

  Author: unknown

  Function: rad2deg performs conversion of radiant to degree

  Source: MiBench
          http://wwweb.eecs.umich.edu/mibench

  Original name: basicmath_small

  Changes: no major functional changes

  License: this code is FREE with no restrictions

*/

#include "init_functions.c"

#include "pi.h"

#define rad2deg(r) ((r)*180/PI)


/*
  Forward declaration of functions
*/

void rad2deg_init( void );
void rad2deg_main( void );
int rad2deg_return( void );
int main( void );


/*
  Declaration of global variables
*/

float rad2deg_X, rad2deg_Y;


/*
  Initialization function
*/

void __attribute__ ((noinline)) rad2deg_init( void )
{
  rad2deg_X = 0;
  rad2deg_Y = 0;
}


/*
  Return function
*/

int __attribute__ ((noinline)) rad2deg_return( void )
{
  int temp = rad2deg_Y;

  if ( temp == 64620 )
    return 0;
  else
    return -1;
}


/*
  Main functions
*/

void __attribute__ ((noinline)) rad2deg_main( void )
{
  _Pragma( "loopbound min 360 max 360" )
  for ( rad2deg_X = 0.0f; rad2deg_X <= ( 2 * PI + 1e-6f ); rad2deg_X += ( PI / 180 ) )
    rad2deg_Y += rad2deg( rad2deg_X );
}


int main(void)
{
    int i;

    switch (__CORE__) {
        case 1: 
            
            printf("\n\n-------------------------- TEST_NAME: RAD2DEG\n\n"); 

            init_test_core1();

            //Tacle-bench
            for (i=0 ; i<__ITERATIONS__ ; i++){
                rad2deg_init();
                rad2deg_main();
            }

            end_test_core1();
            
            printf("\nResult_from_CORE%u:", __CORE__); 
            if ( rad2deg_return()  == 0 ) 
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
                rad2deg_init();
                rad2deg_main();
            }

            end_test_core2();


            *shared_result = rad2deg_return();
            while(1);
            break;

    }
    return(0);
}

