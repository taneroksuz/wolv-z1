default: none

VERILATOR ?= /opt/verilator/bin/verilator
SYSTEMC ?= /opt/systemc
RISCV ?= /opt/riscv/bin
MARCH ?= rv32i
MABI ?= ilp32
ITER ?= 1
CSMITH ?= /opt/csmith
CSMITH_INCL ?= $(shell ls -d $(CSMITH)/include/csmith-* | head -n1)
GCC ?= /usr/bin/gcc
PYTHON ?= /usr/bin/python2
BASEDIR ?= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
OFFSET ?= 0x40000 # Number of dwords in blockram (address range is OFFSET * 8)
TEST ?= dhrystone
CYCLES ?= 10000000
WAVE ?= "" # "wave" for saving dump file

generate_isa:
	soft/isa.sh ${RISCV} ${MARCH} ${MABI} ${PYTHON} ${OFFSET} ${BASEDIR}

generate_dhrystone:
	soft/dhrystone.sh ${RISCV} ${MARCH} ${MABI} ${ITER} ${PYTHON} ${OFFSET} ${BASEDIR}

generate_coremark:
	soft/coremark.sh ${RISCV} ${MARCH} ${MABI} ${ITER} ${PYTHON} ${OFFSET} ${BASEDIR}

generate_csmith:
	soft/csmith.sh ${RISCV} ${MARCH} ${MABI} ${GCC} ${CSMITH} ${CSMITH_INCL} ${PYTHON} ${OFFSET} ${BASEDIR}

generate_torture:
	soft/torture.sh ${RISCV} ${MARCH} ${MABI} ${PYTHON} ${OFFSET} ${BASEDIR}

simulate:
	sim/run.sh ${BASEDIR} ${VERILATOR} ${TEST} ${CYCLES} ${WAVE} ${SYSTEMC}

all: generate_isa generate_dhrystone generate_coremark generate_csmith generate_torture simulate
