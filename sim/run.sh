#!/bin/bash

DIR=${1}

if [ ! -d "$DIR/sim/work" ]; then
  mkdir $DIR/sim/work
fi

VERILATOR=${2}

if [ ! -z "$3" ]
then
  if [ ! "$3" = 'all' ] && [ ! "$3" = 'mi' ] && \
     [ ! "$3" = 'ui' ] && [ ! "$3" = 'um' ] && \
     [ ! "$3" = 'uf' ] && [ ! "$3" = 'uc' ] && \
     [ ! "$3" = 'dhrystone' ] && \
     [ ! "$3" = 'coremark' ] && \
     [ ! "$3" = 'csmith' ] && \
     [ ! "$3" = 'torture' ]
  then
    cp $3 $DIR/sim/work/bram_mem.dat
  fi
fi

if [[ "$4" = [0-9]* ]];
then
  CYCLES="$4"
else
  CYCLES=10000000
fi

cd ${DIR}/sim/work

start=`date +%s`
if [ "$5" = 'wave' ]
then
	${VERILATOR} --cc -Wno-UNOPTFLAT --trace -trace-max-array 128 --trace-structs -f ${DIR}/sim/files.f --top-module test_cpu --exe ${DIR}/verilog/tb/test_cpu_trace.cpp
	make -s -j -C obj_dir/ -f Vtest_cpu.mk Vtest_cpu
	obj_dir/Vtest_cpu
else
	${VERILATOR} --cc -Wno-UNOPTFLAT -f ${DIR}/sim/files.f --top-module test_cpu --exe ${DIR}/verilog/tb/test_cpu.cpp
	make -s -j -C obj_dir/ -f Vtest_cpu.mk Vtest_cpu
	obj_dir/Vtest_cpu
fi
end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
