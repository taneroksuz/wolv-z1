#!/bin/bash

DIR=${1}

if [ ! -d "$DIR/sim/work" ]; then
  mkdir $DIR/sim/work
fi

rm -rf $DIR/sim/work/*

VERILATOR=${2}
SYSTEMC=${3}

export SYSTEMC_LIBDIR=$SYSTEMC/lib-linux64/
export SYSTEMC_INCLUDE=$SYSTEMC/include/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SYSTEMC/lib-linux64/

if [[ "$5" = [0-9]* ]];
then
  CYCLES="$5"
else
  CYCLES=10000000
fi

cd ${DIR}/sim/work

start=`date +%s`
if [ "$6" = 'wave' ]
then
	${VERILATOR} --sc -Wno-UNOPTFLAT --trace -trace-max-array 128 --trace-structs -f ${DIR}/sim/files.f --top-module top_cpu --exe ${DIR}/verilog/tb/top_cpu.cpp
	make -s -j -C obj_dir/ -f Vtop_cpu.mk Vtop_cpu
  if [ "$4" = 'dhrystone' ]
  then
    cp $DIR/build/dhrystone/dat/dhrystone.dat memory.dat
  	obj_dir/Vtop_cpu $CYCLES dhrystone 2> /dev/null
  elif [ "$4" = 'coremark' ]
  then
    cp $DIR/build/coremark/dat/coremark.dat memory.dat
  	obj_dir/Vtop_cpu $CYCLES coremark 2> /dev/null
  elif [ "$4" = 'csmith' ]
  then
    cp $DIR/build/csmith/dat/csmith.dat memory.dat
  	obj_dir/Vtop_cpu $CYCLES csmith 2> /dev/null
  elif [ "$4" = 'torture' ]
  then
    cp $DIR/build/torture/dat/torture.dat memory.dat
  	obj_dir/Vtop_cpu $CYCLES torture 2> /dev/null
  elif [ "$4" = 'uart' ]
  then
    cp $DIR/build/uart/dat/uart.dat memory.dat
  	obj_dir/Vtop_cpu $CYCLES uart 2> /dev/null
  elif [ "$4" = 'ui' ]
  then
    for filename in $DIR/build/isa/dat/rv32ui*.dat; do
      cp $filename memory.dat
      filename=${filename##*/}
      filename=${filename%.dat}
      echo "${filename}"
    	obj_dir/Vtop_cpu $CYCLES ${filename} 2> /dev/null
    done
  else
    cp $DIR/$4 memory.dat
    filename=${3##*/}
    filename=${filename%.dat}
    obj_dir/Vtop_cpu $CYCLES ${filename} 2> /dev/null
  fi
else
	${VERILATOR} --sc -Wno-UNOPTFLAT -f ${DIR}/sim/files.f --top-module top_cpu --exe ${DIR}/verilog/tb/top_cpu.cpp
	make -s -j -C obj_dir/ -f Vtop_cpu.mk Vtop_cpu
  if [ "$4" = 'dhrystone' ]
  then
    cp $DIR/build/dhrystone/dat/dhrystone.dat memory.dat
  	obj_dir/Vtop_cpu $CYCLES 2> /dev/null
  elif [ "$4" = 'coremark' ]
  then
    cp $DIR/build/coremark/dat/coremark.dat memory.dat
  	obj_dir/Vtop_cpu $CYCLES 2> /dev/null
  elif [ "$4" = 'csmith' ]
  then
    cp $DIR/build/csmith/dat/csmith.dat memory.dat
  	obj_dir/Vtop_cpu $CYCLES 2> /dev/null
  elif [ "$4" = 'torture' ]
  then
    cp $DIR/build/torture/dat/torture.dat memory.dat
  	obj_dir/Vtop_cpu $CYCLES 2> /dev/null
  elif [ "$4" = 'uart' ]
  then
    cp $DIR/build/uart/dat/uart.dat memory.dat
  	obj_dir/Vtop_cpu $CYCLES 2> /dev/null
  elif [ "$4" = 'ui' ]
  then
    for filename in $DIR/build/isa/dat/rv32ui*.dat; do
      cp $filename memory.dat
      filename=${filename##*/}
      filename=${filename%.dat}
      echo "${filename}"
    	obj_dir/Vtop_cpu $CYCLES 2> /dev/null
    done
  else
    cp $DIR/$4 memory.dat
    obj_dir/Vtop_cpu $CYCLES 2> /dev/null
  fi
fi
end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
