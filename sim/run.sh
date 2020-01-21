#!/bin/bash

DIR=${1}

if [ ! -d "$DIR/sim/work" ]; then
  mkdir $DIR/sim/work
fi

VERILATOR=${2}

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
  if [ "$3" = 'dhrystone' ]
  then
    cp $DIR/build/dhrystone/dat/dhrystone.dat memory.dat
  	obj_dir/Vtest_cpu $CYCLES dhrystone
  elif [ "$3" = 'coremark' ]
  then
    cp $DIR/build/coremark/dat/coremark.dat memory.dat
  	obj_dir/Vtest_cpu $CYCLES coremark
  elif [ "$3" = 'csmith' ]
  then
    cp $DIR/build/csmith/dat/csmith.dat memory.dat
  	obj_dir/Vtest_cpu $CYCLES csmith
  elif [ "$3" = 'torture' ]
  then
    cp $DIR/build/torture/dat/torture.dat memory.dat
  	obj_dir/Vtest_cpu $CYCLES torture
  elif [ "$3" = 'ui' ]
  then
    for filename in $DIR/build/isa/dat/rv32ui*.dat; do
      cp $filename memory.dat
      filename=${filename##*/}
      filename=${filename%.dat}
      echo "${filename}"
    	obj_dir/Vtest_cpu $CYCLES ${filename}
    done
  else
    cp $3 memory.dat
    obj_dir/Vtest_cpu $CYCLES
  fi
else
	${VERILATOR} --cc -Wno-UNOPTFLAT -f ${DIR}/sim/files.f --top-module test_cpu --exe ${DIR}/verilog/tb/test_cpu.cpp
	make -s -j -C obj_dir/ -f Vtest_cpu.mk Vtest_cpu
  if [ "$3" = 'dhrystone' ]
  then
    cp $DIR/build/dhrystone/dat/dhrystone.dat memory.dat
  	obj_dir/Vtest_cpu $CYCLES
  elif [ "$3" = 'coremark' ]
  then
    cp $DIR/build/coremark/dat/coremark.dat memory.dat
  	obj_dir/Vtest_cpu $CYCLES
  elif [ "$3" = 'csmith' ]
  then
    cp $DIR/build/csmith/dat/csmith.dat memory.dat
  	obj_dir/Vtest_cpu $CYCLES
  elif [ "$3" = 'torture' ]
  then
    cp $DIR/build/torture/dat/torture.dat memory.dat
  	obj_dir/Vtest_cpu $CYCLES
  elif [ "$3" = 'ui' ]
  then
    for filename in $DIR/build/isa/dat/rv32ui*.dat; do
      cp $filename memory.dat
      filename=${filename##*/}
      filename=${filename%.dat}
      echo "${filename}"
    	obj_dir/Vtest_cpu $CYCLES
    done
  else
    cp $3 memory.dat
    obj_dir/Vtest_cpu $CYCLES
  fi
fi
end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
