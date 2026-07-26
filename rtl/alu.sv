`default_nettype none

module alu (
    input  wire [63:0] a,
    input  wire [63:0] b,
    input  wire [3:0]  alu_op,
    output logic [63:0] result,
    output logic       zero
);

    always_comb begin
        case (alu_op)
            4'b0000: result = a + b;           
            4'b1000: result = a - b;           
            4'b0001: result = a << b[5:0];     
            4'b0010: result = ($signed(a) < $signed(b)) ? 64'b1 : 64'b0; 
            4'b0011: result = (a < b) ? 64'b1 : 64'b0; 
            4'b0100: result = a ^ b;           
            4'b0101: result = a >> b[5:0];     
            4'b1101: result = $signed(a) >>> b[5:0]; 
            4'b0110: result = a | b;           
            4'b0111: result = a & b;           
            default: result = 64'b0;
        endcase
    end

    assign zero = (result == 64'b0);

endmodule

