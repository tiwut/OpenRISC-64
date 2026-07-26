`default_nettype none

module pc (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        stall,
    input  wire        branch_en,
    input  wire [63:0] branch_target,
    output reg  [63:0] pc_out
);

    
    localparam BOOT_ADDR = 64'h0000000080000000;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_out <= BOOT_ADDR;
        end else if (!stall) begin
            if (branch_en) begin
                pc_out <= branch_target;
            end else begin
                pc_out <= pc_out + 64'd4;
            end
        end
    end

endmodule

