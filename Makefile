# OpenRISC-64 Makefile
# Configured for Verilator & C++ Testbench

VERILATOR = verilator
VERILATOR_FLAGS = -Wall -Wno-WIDTH -Wno-WIDTHTRUNC -Wno-UNUSEDSIGNAL -Wno-UNUSEDPARAM -Wno-CASEINCOMPLETE -Wno-UNOPTFLAT --cc --trace --exe --build --top-module core

RTL_SRC = rtl/*.sv
TB_SRC = tb/tb_core.cpp

TARGET = Vcore
OBJ_DIR = obj_dir

.PHONY: all build sim wave clean

all: sim

firmware:
	riscv64-unknown-elf-gcc -march=rv64i_zicsr -mabi=lp64 -nostdlib -T tests/link.ld tests/test.s -o tests/firmware.elf
	riscv64-unknown-elf-objcopy -O verilog --change-addresses=-0x80000000 tests/firmware.elf firmware.hex

build: $(OBJ_DIR)/$(TARGET) firmware

# Build the executable using Verilator
$(OBJ_DIR)/$(TARGET): $(RTL_SRC) $(TB_SRC)
	$(VERILATOR) $(VERILATOR_FLAGS) $(RTL_SRC) $(TB_SRC) -j 0

# Run the simulation
sim: build
	./$(OBJ_DIR)/$(TARGET)

# Open waveform in GTKWave
wave: sim
	gtkwave waveform.vcd &

clean:
	rm -rf $(OBJ_DIR) waveform.vcd tests/*.elf *.hex
