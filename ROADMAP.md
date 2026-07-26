# Development Roadmap & Checklist

This document serves as the step-by-step execution path for developing the RV64 Core. Tasks are marked as completed as development progresses.

---

## Phase 1: Environment & Toolchain Setup
- [ ] Install and configure **Verilator** and **GTKWave**.
- [ ] Set up `riscv64-unknown-elf-gcc` cross-compiler.
- [ ] Create automated `Makefile` for compiling SystemVerilog modules and launching C++ testbenches.

---

## Phase 2: Single-Cycle RV64I Base Core
- [ ] **Program Counter (PC):** Implement 64-bit PC register with increment logic (`PC + 4`).
- [ ] **Instruction Fetch / Memory Interface:** Build basic memory module loading `.hex` binaries.
- [ ] **Instruction Decoder:** Implement R-Type, I-Type, S-Type, B-Type, U-Type, and J-Type RV64 decoding logic.
- [ ] **Register File:** Create 32x64-bit register bank (`x0` hardwired to `0`).
- [ ] **ALU (Arithmetic Logic Unit):**
  - [ ] Basic arithmetic: `ADD`, `ADDI`, `SUB`, `ADDW`, `SUBW` (64-bit & 32-bit word operations).
  - [ ] Logical: `AND`, `OR`, `XOR`, `SLT`, `SLTU`.
  - [ ] Shift logic: `SLL`, `SRL`, `SRA`, `SLLW`, `SRLW`, `SRAW`.
- [ ] **Control Unit:** Manage execution flags, immediate generation, and writeback routing.
- [ ] **Branch & Jump Logic:** Implement `BEQ`, `BNE`, `BLT`, `BGE`, `JAL`, `JALR`.
- [ ] **Load / Store Unit (LSU):** Implement byte, half-word, word, and double-word memory operations (`LB`, `LH`, `LW`, `LD`, `SB`, `SH`, `SW`, `SD`).

---

## Phase 3: Verification & Simple C Execution
- [ ] Write bare-metal RISC-V assembly test cases.
- [ ] Run C program compiled via `riscv64-gcc` inside Verilator simulation.
- [ ] Verify register values and memory state via `GTKWave`.

---

## Phase 4: Pipelining (5-Stage Architecture)
- [ ] Split core into 5 pipeline stages: **Fetch (IF)**, **Decode (ID)**, **Execute (EX)**, **Memory (MEM)**, **Writeback (WB)**.
- [ ] Insert pipeline registers between stages.
- [ ] Implement **Data Hazard Detection & Forwarding Unit**.
- [ ] Implement **Control Hazard Unit** (branch misprediction handling/flushing).

---

## Phase 5: Privileged Architecture & MMU (OS Support)
- [ ] Implement **Privilege Modes:** Machine Mode (M-Mode), Supervisor Mode (S-Mode), User Mode (U-Mode).
- [ ] Implement **Control & Status Registers (CSRs)** for exception handling, timers, and interrupts.
- [ ] Implement **SV39 Memory Management Unit (MMU)** for virtual memory page translation.
- [ ] Boot **OpenSBI** (Supervisor Binary Interface) in Verilator simulation.
- [ ] Boot minimal **Linux Kernel** console output over simulated UART.

---

## Phase 6: Multi-Core Readiness & Interconnect Design
- [ ] Standardize bus interface to **AXI4** or **Wishbone** for external communication.
- [ ] Add L1 Instruction and L1 Data Cache modules.
- [ ] Design CPU tile wrapper with interrupt routing (PLIC/CLINT) and core ID configuration (`mhartid`).
- [ ] Integrate 2 or more instances of the single-core CPU via interconnect (Multi-core scaling).

---

## Phase 7: Hardware Deployment (FPGA & Tape-out)
- [ ] Synthesize single core using **Yosys** & **nextpnr**.
- [ ] Program design onto FPGA board (e.g., Digilent Arty A7 / Lattice ECP5).
- [ ] Prepare GDSII layout via **OpenLane** / **Tiny Tapeout** for physical silicon manufacturing.
