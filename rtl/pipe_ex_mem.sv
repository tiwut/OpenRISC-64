`default_nettype none

module pipe_ex_mem (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        flush,
    input  wire        stall,
    
    
    input  wire [63:0] alu_result_in,
    input  wire [63:0] rdata2_in, 
    input  wire [63:0] pc_in, 
    input  wire [63:0] imm_out_in, 
    
    
    input  wire [4:0]  rd_in,
    
    
    input  wire        reg_write_in,
    input  wire        mem_read_in,
    input  wire        mem_write_in,
    input  wire [1:0]  mem_to_reg_in,
    input  wire [2:0]  funct3_in,
    
    
    output logic [63:0] alu_result_out,
    output logic [63:0] rdata2_out,
    output logic [63:0] pc_out,
    output logic [63:0] imm_out_out,
    
    output logic [4:0]  rd_out,
    
    output logic        reg_write_out,
    output logic        mem_read_out,
    output logic        mem_write_out,
    output logic [1:0]  mem_to_reg_out,
    output logic [2:0]  funct3_out
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            alu_result_out <= 64'b0;
            rdata2_out     <= 64'b0;
            pc_out         <= 64'b0;
            imm_out_out    <= 64'b0;
            rd_out         <= 5'b0;
            reg_write_out  <= 1'b0;
            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;
            mem_to_reg_out <= 2'b0;
            funct3_out     <= 3'b0;
        end else if (flush) begin
            alu_result_out <= 64'b0;
            rdata2_out     <= 64'b0;
            pc_out         <= 64'b0;
            imm_out_out    <= 64'b0;
            rd_out         <= 5'b0;
            reg_write_out  <= 1'b0;
            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;
            mem_to_reg_out <= 2'b0;
            funct3_out     <= 3'b0;
        end else if (!stall) begin
            alu_result_out <= alu_result_in;
            rdata2_out     <= rdata2_in;
            pc_out         <= pc_in;
            imm_out_out    <= imm_out_in;
            rd_out         <= rd_in;
            reg_write_out  <= reg_write_in;
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            funct3_out     <= funct3_in;
        end
    end
endmodule

