#include "Vtest_cpu.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <iostream>
#include <string.h>
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
  string file;
  Verilated::commandArgs(argc, argv);

  Vtest_cpu* top = new Vtest_cpu;

  if (argc > 2)
  {
    file = string(argv[2]) + string(".vcd");
  }
  const char *wave = file.c_str();

  Verilated::traceEverOn(true);
  VerilatedVcdC* vcd = new VerilatedVcdC;
  top->trace (vcd, 99);
  vcd->open (wave);

  top->clk = 0;
  top->rst = 0;

  i = 0;
  while (1)
  {
    vcd->dump (i);
    top->rst = (i > 10);
    top->clk = !top->clk;
    top->eval ();
    if (Verilated::gotFinish())
    {
      exit(0);
    }
    i++;
    main_time++;

    if (argc > 1 && main_time == 2*strtol(argv[1], &p, 20))
    {
      exit(0);
    }
  }

  vcd->close();
  exit(0);
}
