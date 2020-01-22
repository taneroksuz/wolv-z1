#include "Vtest_cpu.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <iostream>
#include <stdlib.h>

vluint64_t main_time = 0;

double sc_time_stamp()
{
  return main_time;
}

using namespace std;

int main(int argc, char **argv, char **env)
{
  int i;
  char *p;
  Verilated::commandArgs(argc, argv);

  Vtest_cpu* top = new Vtest_cpu;

  top->clk = 1;
  top->rst = 0;

  i = 0;
  while (1)
  {
    top->rst = (i > 10);
    top->clk = !top->clk;
    top->eval ();
    if (Verilated::gotFinish())
    {
      exit(0);
    }
    i++;
    main_time++;

    if (argc == 2 && main_time == 2*strtol(argv[1], &p, 20))
    {
      exit(0);
    }
  }

  exit(0);
}
