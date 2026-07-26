`default_nettype none

module regfile (
    input  wire        clk,
    input  wire [4:0]  rs1,
    input  wire [4:0]  rs2,
    input  wire [4:0]  rd,
    input  wire [63:0] wdata,
    input  wire        we,
    output wire [63:0] rdata1,
    output wire [63:0] rdata2
);

    reg [63:0] regs [0:31];

    assign rdata1 = (rs1 == 5'b0) ? 64'b0 : regs[rs1];
    assign rdata2 = (rs2 == 5'b0) ? 64'b0 : regs[rs2];

    always_ff @(posedge clk) begin
        if (we && rd != 5'b0) begin
            regs[rd] <= wdata;
        end
    end

    
    initial begin
        for (int i = 0; i < 32; i++) begin
            regs[i] = 64'b0;
        end
    end

endmodule

