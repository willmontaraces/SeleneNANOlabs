/*

  This program is part of the TACLeBench benchmark suite.
  Version V 2.0

  Name: prime

  Author: unknown

  Function: prime calculates whether numbers are prime.

  Source: MRTC
          http://www.mrtc.mdh.se/projects/wcet/wcet_bench/prime/prime.c

  Changes: no major functional changes

  License: may be used, modified, and re-distributed freely

*/

#include "init_functions.c"

/*
  Forward declaration of functions
*/

unsigned char prime_divides ( unsigned int n, unsigned int m );
unsigned char prime_even ( unsigned int n );
unsigned char prime_prime ( unsigned int n );
void prime_swap ( unsigned int *a, unsigned int *b );
unsigned int prime_randomInteger();
void prime_initSeed();
void prime_init ();
int prime_return ();
void prime_main ();
int main( void );


/*
  Declaration of global variables
*/

unsigned int prime_x;
unsigned int prime_y;
int prime_result;
volatile int prime_seed;


/*
  Initialization- and return-value-related functions
*/


void prime_initSeed()
{
  prime_seed = 0;
}


unsigned int prime_randomInteger()
{
  prime_seed = ( ( prime_seed * 133 ) + 81 ) % 8095;
  return ( prime_seed );
}


void  __attribute__ ((noinline)) prime_init ()
{
  prime_initSeed();

  prime_x = prime_randomInteger();
  prime_y = prime_randomInteger();
}


int  __attribute__ ((noinline)) prime_return ()
{
  return prime_result;
}


/*
  Algorithm core functions
*/

unsigned char prime_divides ( unsigned int n, unsigned int m )
{
  return ( m % n == 0 );
}


unsigned char prime_even ( unsigned int n )
{
  return ( prime_divides ( 2, n ) );
}


unsigned char prime_prime ( unsigned int n )
{
  unsigned int i;
  if ( prime_even ( n ) )
    return ( n == 2 );
  _Pragma( "loopbound min 0 max 16" )               
  for ( i = 3; i * i <= n; i += 2 ) {
    if ( prime_divides ( i, n ) ) /* ai: loop here min 0 max 357 end; */
      return 0;
  }
  return ( n > 1 );
}


void prime_swap ( unsigned int *a, unsigned int *b )
{
  unsigned int tmp = *a;
  *a = *b;
  *b = tmp;
}


/*
  Main functions
*/

void  __attribute__ ((noinline)) prime_main()
{
  prime_swap ( &prime_x, &prime_y );

  prime_result = !( !prime_prime( prime_x ) && !prime_prime( prime_y ) );
}


int main(void)
{
    int i;

    switch (__CORE__) {
        case 1: 
            
            printf("\n\n-------------------------- TEST_NAME: PRIME\n\n"); 

            init_test_core1();

            //Tacle-bench
            for (i=0 ; i<__ITERATIONS__ ; i++){
                prime_init();
                prime_main();
            }

            end_test_core1();
            
            printf("\nResult_from_CORE%u:", __CORE__); 
            if ( prime_return()  == 0 ) 
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
                prime_init();
                prime_main();
            }

            end_test_core2();


            *shared_result = prime_return();
            while(1);
            break;

    }
    return(0);
}

