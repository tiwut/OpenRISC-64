`default_nettype none

module memory #(
    parameter SIZE_BYTES = 8192,
    parameter INIT_FILE = "firmware.hex"
) (
    input  wire        clk,
    
    
    input  wire [63:0] if_addr,
    output logic [31:0] if_inst,
    
    
    input  wire [63:0] mem_addr,
    input  wire [63:0] mem_wdata,
    input  wire [7:0]  mem_wmask, 
    input  wire        mem_we,
    input  wire        mem_re,
    output logic [63:0] mem_rdata,
    
    
    input  wire [63:0] ptw0_addr, 
    output logic [63:0] ptw0_rdata,
    
    input  wire [63:0] ptw1_addr, 
    output logic [63:0] ptw1_rdata
);

    
    logic [7:0] mem_array [0:SIZE_BYTES-1];

    
    localparam BASE_ADDR = 64'h0000_0000_8000_0000;

    initial begin
        
        for (int i = 0; i < SIZE_BYTES; i++) begin
            mem_array[i] = 8'b0;
        end
        
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, mem_array);
        end
    end

    
    wire [63:0] if_offset = if_addr - BASE_ADDR;

    always_comb begin
        if (if_addr >= BASE_ADDR && if_offset < SIZE_BYTES) begin
            if_inst = {mem_array[if_offset+3], mem_array[if_offset+2], mem_array[if_offset+1], mem_array[if_offset]};
        end else begin
            if_inst = 32'h00000013; 
        end
    end

    
    wire [63:0] mem_offset = mem_addr - BASE_ADDR;

    always_ff @(posedge clk) begin
        if (mem_we && mem_addr >= BASE_ADDR && mem_offset < SIZE_BYTES) begin
            if (mem_wmask[0]) mem_array[mem_offset]   <= mem_wdata[7:0];
            if (mem_wmask[1]) mem_array[mem_offset+1] <= mem_wdata[15:8];
            if (mem_wmask[2]) mem_array[mem_offset+2] <= mem_wdata[23:16];
            if (mem_wmask[3]) mem_array[mem_offset+3] <= mem_wdata[31:24];
            if (mem_wmask[4]) mem_array[mem_offset+4] <= mem_wdata[39:32];
            if (mem_wmask[5]) mem_array[mem_offset+5] <= mem_wdata[47:40];
            if (mem_wmask[6]) mem_array[mem_offset+6] <= mem_wdata[55:48];
            if (mem_wmask[7]) mem_array[mem_offset+7] <= mem_wdata[63:56];
        end
    end

    always_comb begin
        if (mem_re && mem_addr >= BASE_ADDR && mem_offset < SIZE_BYTES) begin
            mem_rdata = {
                mem_array[mem_offset+7], mem_array[mem_offset+6], mem_array[mem_offset+5], mem_array[mem_offset+4],
                mem_array[mem_offset+3], mem_array[mem_offset+2], mem_array[mem_offset+1], mem_array[mem_offset]
            };
        end else begin
            mem_rdata = 64'b0;
        end
    end

    
    wire [63:0] ptw0_offset = ptw0_addr - BASE_ADDR;
    wire [63:0] ptw1_offset = ptw1_addr - BASE_ADDR;

    always_comb begin
        if (ptw0_addr >= BASE_ADDR && ptw0_offset < SIZE_BYTES) begin
            ptw0_rdata = {
                mem_array[ptw0_offset+7], mem_array[ptw0_offset+6], mem_array[ptw0_offset+5], mem_array[ptw0_offset+4],
                mem_array[ptw0_offset+3], mem_array[ptw0_offset+2], mem_array[ptw0_offset+1], mem_array[ptw0_offset]
            };
        end else begin
            ptw0_rdata = 64'b0;
        end
        
        if (ptw1_addr >= BASE_ADDR && ptw1_offset < SIZE_BYTES) begin
            ptw1_rdata = {
                mem_array[ptw1_offset+7], mem_array[ptw1_offset+6], mem_array[ptw1_offset+5], mem_array[ptw1_offset+4],
                mem_array[ptw1_offset+3], mem_array[ptw1_offset+2], mem_array[ptw1_offset+1], mem_array[ptw1_offset]
            };
        end else begin
            ptw1_rdata = 64'b0;
        end
    end

endmodule

