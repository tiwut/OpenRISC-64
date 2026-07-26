
#include <verilated_vcd_c.h>
#include "Vcore.h"
#include <iostream>
#include <vector>
#include <fstream>


#define RAM_SIZE (64 * 1024 * 1024)
std::vector<uint8_t> ram(RAM_SIZE, 0);

void load_binary(const char* filename, uint64_t addr) {
    std::ifstream file(filename, std::ios::binary);
    if (!file) {
        std::cerr << "Warning: Could not open " << filename << std::endl;
        return;
    }
    file.seekg(0, std::ios::end);
    size_t size = file.tellg();
    file.seekg(0, std::ios::beg);
    
    if (addr + size > RAM_SIZE) {
        std::cerr << "Error: Binary too large for RAM" << std::endl;
        return;
    }
    
    file.read(reinterpret_cast<char*>(&ram[addr]), size);
    std::cout << "Loaded " << filename << " (" << size << " bytes) at 0x" << std::hex << addr << std::endl;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    Vcore* top = new Vcore;
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("waveform.vcd");

    
    
    
    
    top->clk = 0;
    top->rst_n = 0;
    top->timer_irq = 0;

    int sim_time = 0;
    const int MAX_SIM_TIME = 2000;

    std::cout << "Starting Linux-capable RV64 Verilator simulation..." << std::endl;

    while (sim_time < MAX_SIM_TIME && !Verilated::gotFinish()) {
        if (sim_time > 10) {
            top->rst_n = 1;
        }

        top->clk = !top->clk;
        top->eval();
        tfp->dump(sim_time);
        sim_time++;
    }

    std::cout << "Simulation finished. Waveform saved to waveform.vcd" << std::endl;

    tfp->close();
    delete top;
    delete tfp;
    return 0;
}

