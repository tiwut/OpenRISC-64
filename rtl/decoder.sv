`default_nettype none

module decoder (
    input  wire [31:0] inst,
    output logic [6:0] opcode,
    output logic [4:0] rd,
    output logic [2:0] funct3,
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [6:0] funct7,
    output logic [63:0] imm_i,
    output logic [63:0] imm_s,
    output logic [63:0] imm_b,
    output logic [63:0] imm_u,
    output logic [63:0] imm_j
);

    assign opcode = inst[6:0];
    assign rd     = inst[11:7];
    assign funct3 = inst[14:12];
    assign rs1    = inst[19:15];
    assign rs2    = inst[24:20];
    assign funct7 = inst[31:25];

    
    assign imm_i = {{53{inst[31]}}, inst[30:20]};
    assign imm_s = {{53{inst[31]}}, inst[30:25], inst[11:7]};
    assign imm_b = {{52{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
    assign imm_u = {{32{inst[31]}}, inst[31:12], 12'b0};
    assign imm_j = {{44{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};

endmodule

