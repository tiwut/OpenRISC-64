`default_nettype none

module branch_unit (
    input  wire [63:0] rs1_data,
    input  wire [63:0] rs2_data,
    input  wire [63:0] pc,
    input  wire [63:0] imm,
    input  wire [2:0]  funct3,
    input  wire        branch,
    input  wire        jump,
    input  wire        jalr,
    output logic       branch_en,
    output logic [63:0] branch_target
);

    logic take_branch;

    always_comb begin
        take_branch = 1'b0;
        if (branch) begin
            case (funct3)
                3'b000: take_branch = (rs1_data == rs2_data); 
                3'b001: take_branch = (rs1_data != rs2_data); 
                3'b100: take_branch = ($signed(rs1_data) < $signed(rs2_data)); 
                3'b101: take_branch = ($signed(rs1_data) >= $signed(rs2_data)); 
                3'b110: take_branch = (rs1_data < rs2_data); 
                3'b111: take_branch = (rs1_data >= rs2_data); 
                default: take_branch = 1'b0;
            endcase
        end
    end

    assign branch_en = jump | jalr | take_branch;

    always_comb begin
        if (jalr) begin
            
            branch_target = (rs1_data + imm) & ~64'd1;
        end else begin
            
            branch_target = pc + imm;
        end
    end

endmodule

