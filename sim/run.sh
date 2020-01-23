#!/bin/bash

DIR=${1}

if [ ! -d "$DIR/sim/work" ]; then
  mkdir $DIR/sim/work
fi

rm -rf $DIR/sim/work/*

VERILATOR=${2}
SYSTEMC=${6}

export SYSTEMC_LIBDIR=$SYSTEMC/lib-linux64/
export SYSTEMC_INCLUDE=$SYSTEMC/include/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SYSTEMC/lib-linux64/

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
	${VERILATOR} --sc -Wno-UNOPTFLAT --trace -trace-max-array 128 --trace-structs -f ${DIR}/sim/files.f --top-module test_cpu --exe ${DIR}/verilog/tb/test_cpu.cpp
	make -s -j -C obj_dir/ -f Vtest_cpu.mk Vtest_cpu
  if [ "$3" = 'dhrystone' ]
  then
    cp $DIR/build/dhrystone/dat/dhrystone.dat memory.dat
  	obj_dir/Vtest_cpu $CYCLES dhrystone 2> /dev/null
  elif [ "$3" = 'coremark' ]
  then
    cp $DIR/build/coremark/dat/coremark.dat memory.dat
  	obj_dir/Vtest_cpu $CYCLES coremark 2> /dev/null
  elif [ "$3" = 'csmith' ]
  then
    cp $DIR/build/csmith/dat/csmith.dat memory.dat
  	obj_dir/Vtest_cpu $CYCLES csmith 2> /dev/null
  elif [ "$3" = 'torture' ]
  then
    cp $DIR/build/torture/dat/torture.dat memory.dat
  	obj_dir/Vtest_cpu $CYCLES torture 2> /dev/null
  elif [ "$3" = 'ui' ]
  then
    for filename in $DIR/build/isa/dat/rv32ui*.dat; do
      cp $filename memory.dat
      filename=${filename##*/}
      filename=${filename%.dat}
      echo "${filename}"
    	obj_dir/Vtest_cpu $CYCLES ${filename} 2> /dev/null
    done
  else
    cp $DIR/$3 memory.dat
    filename=${3##*/}
    filename=${filename%.dat}
    obj_dir/Vtest_cpu $CYCLES ${filename} 2> /dev/null
  fi
else
	${VERILATOR} --sc -Wno-UNOPTFLAT -f ${DIR}/sim/files.f --top-module test_cpu --exe ${DIR}/verilog/tb/test_cpu.cpp
	make -s -j -C obj_dir/ -f Vtest_cpu.mk Vtest_cpu
  if [ "$3" = 'dhrystone' ]
  then
    cp $DIR/build/dhrystone/dat/dhrystone.dat memory.dat
  	obj_dir/Vtest_cpu $CYCLES 2> /dev/null
  elif [ "$3" = 'coremark' ]
  then
    cp $DIR/build/coremark/dat/coremark.dat memory.dat
  	obj_dir/Vtest_cpu $CYCLES 2> /dev/null
  elif [ "$3" = 'csmith' ]
  then
    cp $DIR/build/csmith/dat/csmith.dat memory.dat
  	obj_dir/Vtest_cpu $CYCLES 2> /dev/null
  elif [ "$3" = 'torture' ]
  then
    cp $DIR/build/torture/dat/torture.dat memory.dat
  	obj_dir/Vtest_cpu $CYCLES 2> /dev/null
  elif [ "$3" = 'ui' ]
  then
    for filename in $DIR/build/isa/dat/rv32ui*.dat; do
      cp $filename memory.dat
      filename=${filename##*/}
      filename=${filename%.dat}
      echo "${filename}"
    	obj_dir/Vtest_cpu $CYCLES 2> /dev/null
    done
  else
    cp $DIR/$3 memory.dat
    obj_dir/Vtest_cpu $CYCLES 2> /dev/null
  fi
fi
end=`date +%s`
echo Execution time was `expr $end - $start` seconds.
