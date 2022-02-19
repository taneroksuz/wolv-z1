default: none

VERILATOR ?= /opt/verilator/bin/verilator
SYSTEMC ?= /opt/systemc
RISCV ?= /opt/riscv/bin
SV2V ?= /opt/sv2v/bin/sv2v
MARCH ?= rv32imc_zba_zbb_zbc
MABI ?= ilp32
ITER ?= 10
CSMITH ?= /opt/csmith
CSMITH_INCL ?= $(shell ls -d $(CSMITH)/include/csmith-* | head -n1)
GCC ?= /usr/bin/gcc
PYTHON ?= /usr/bin/python2
BASEDIR ?= $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
OVP ?= riscv-ovpsim-plus-bitmanip-tests.zip
OFFSET ?= 0x80000 # Number of dwords in blockram (address range is OFFSET * 8)
TEST ?= dhrystone
AAPG ?= aapg
CONFIG ?= integer
CYCLES ?= 10000000000
FPGA ?= quartus # tb vivado quartus
WAVE ?= "" # "wave" for saving dump file

generate:
	@if [ ${TEST} = "compliance" ]; \
	then \
		soft/compliance.sh ${RISCV} ${MARCH} ${MABI} ${XLEN} ${PYTHON} ${OFFSET} ${BASEDIR}; \
	elif [ ${TEST} = "ovp" ]; \
	then \
		soft/ovp.sh ${RISCV} ${MARCH} ${MABI} ${XLEN} ${PYTHON} ${OFFSET} ${BASEDIR} ${OVP}; \
	elif [ ${TEST} = "dhrystone" ]; \
	then \
		soft/dhrystone.sh ${RISCV} ${MARCH} ${MABI} ${ITER} ${PYTHON} ${OFFSET} ${BASEDIR}; \
	elif [ ${TEST} = "coremark" ]; \
	then \
		soft/coremark.sh ${RISCV} ${MARCH} ${MABI} ${ITER} ${PYTHON} ${OFFSET} ${BASEDIR}; \
	elif [ ${TEST} = "csmith" ]; \
	then \
		soft/csmith.sh ${RISCV} ${MARCH} ${MABI} ${GCC} ${CSMITH} ${CSMITH_INCL} ${PYTHON} ${OFFSET} ${BASEDIR}; \
	elif [ ${TEST} = "torture" ]; \
	then \
		soft/torture.sh ${RISCV} ${MARCH} ${MABI} ${PYTHON} ${OFFSET} ${BASEDIR}; \
	elif [ ${TEST} = "uart" ]; \
	then \
		soft/uart.sh ${RISCV} ${MARCH} ${MABI} ${ITER} ${PYTHON} ${OFFSET} ${BASEDIR}; \
	elif [ ${TEST} = "timer" ]; \
	then \
		soft/timer.sh ${RISCV} ${MARCH} ${MABI} ${ITER} ${PYTHON} ${OFFSET} ${BASEDIR}; \
	elif [ ${TEST} = "aapg" ]; \
	then \
		soft/aapg.sh ${RISCV} ${MARCH} ${MABI} ${ITER} ${PYTHON} ${OFFSET} ${BASEDIR} ${AAPG} ${CONFIG}; \
	fi

simulate:
	sim/run.sh ${BASEDIR} ${VERILATOR} ${SYSTEMC} ${TEST} ${CYCLES} ${WAVE}

synthesis:
	synth/generate.sh ${BASEDIR} ${SV2V} ${FPGA} ${TEST}

all: generate_dhrystone generate_coremark generate_csmith generate_torture simulate
