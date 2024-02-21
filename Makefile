DPU_DIR := dpu
HOST_DIR := host
BUILDDIR ?= bin
NR_TASKLETS ?= 16 
BL ?= 10
NR_DPUS ?= 1 

HOST_TARGET := ${BUILDDIR}/gemv_host
DPU_TARGET := ${BUILDDIR}/gemv_dpu

COMMON_INCLUDES := support
HOST_SOURCES := $(wildcard ${HOST_DIR}/*.c)
DPU_SOURCES := $(wildcard ${DPU_DIR}/*.c)

.PHONY: all clean test

__dirs := $(shell mkdir -p ${BUILDDIR})

COMMON_FLAGS := -Wall -Wextra -g -I${COMMON_INCLUDES}
HOST_FLAGS := ${COMMON_FLAGS} -std=c11 -O3 `dpu-pkg-config --cflags --libs dpu` -DNR_TASKLETS=${NR_TASKLETS} -DNR_DPUS=${NR_DPUS} -DBL=${BL}
DPU_FLAGS := ${COMMON_FLAGS} -O2 -DNR_TASKLETS=${NR_TASKLETS} -DBL=${BL}

all: ${HOST_TARGET} ${DPU_TARGET}

${HOST_TARGET}: ${HOST_SOURCES} ${COMMON_INCLUDES}
	$(CC) -o $@ ${HOST_SOURCES} ${HOST_FLAGS}

${DPU_TARGET}: ${DPU_SOURCES} ${COMMON_INCLUDES}
	dpu-upmem-dpurte-clang ${DPU_FLAGS} -o $@ ${DPU_SOURCES}

clean:
	$(RM) -r $(BUILDDIR)

test: all
	./${HOST_TARGET} -m 1024 -n 1024