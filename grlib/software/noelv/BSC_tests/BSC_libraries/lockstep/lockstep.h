#include <lockstep_vars.h>

void lockstep_masked_and_write (unsigned int entry, unsigned int mask);
void lockstep_masked_or_write (unsigned int entry, unsigned int mask);
void write (unsigned int entry, unsigned int value);
void start_lockstep(void);
void activate_lockstep(int min_slack, int max_slack);
void configure_lockstep(int min_slack, int max_slack);
void stop_lockstep(void);
void reset_lockstep_counters(void);
unsigned int read (unsigned int entry);
void print_results(void);
