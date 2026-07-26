`default_nettype none

module pipe_if_id (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        flush,
    input  wire        stall,
    
    input  wire [63:0] pc_in,
    input  wire [31:0] inst_in,
    input  wire        inst_page_fault_in,
    
    output logic [63:0] pc_out,
    output logic [31:0] inst_out,
    output logic        inst_page_fault_out
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_out   <= 64'b0;
            inst_out <= 32'h00000013; 
            inst_page_fault_out <= 1'b0;
        end else if (flush) begin
            pc_out   <= 64'b0;
            inst_out <= 32'h00000013; 
            inst_page_fault_out <= 1'b0;
        end else if (!stall) begin
            pc_out   <= pc_in;
            inst_out <= inst_in;
            inst_page_fault_out <= inst_page_fault_in;
        end
    end

endmodule

