`default_nettype none

module control (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    
    
    input  wire [63:0] imm_i,
    input  wire [63:0] imm_s,
    input  wire [63:0] imm_b,
    input  wire [63:0] imm_u,
    input  wire [63:0] imm_j,
    
    
    output logic       reg_write,
    output logic [1:0] alu_src_a, 
    output logic [1:0] alu_src_b, 
    output logic [3:0] alu_op,
    output logic       mem_read,
    output logic       mem_write,
    output logic [1:0] mem_to_reg, 
    output logic       branch,
    output logic       jump,
    output logic       jalr,
    output logic       ecall,
    output logic       ebreak,
    output logic       mret,
    output logic       sret,
    output logic       csr_en,
    output logic [1:0] csr_op,
    output logic       csr_imm_sel,
    output logic [63:0] imm_out
);

    localparam OP_LUI    = 7'b0110111;
    localparam OP_AUIPC  = 7'b0010111;
    localparam OP_JAL    = 7'b1101111;
    localparam OP_JALR   = 7'b1100111;
    localparam OP_BRANCH = 7'b1100011;
    localparam OP_LOAD   = 7'b0000011;
    localparam OP_STORE  = 7'b0100011;
    localparam OP_IMM    = 7'b0010011;
    localparam OP_OP     = 7'b0110011;
    localparam OP_SYSTEM = 7'b1110011;

    always_comb begin
        
        reg_write  = 1'b0;
        alu_src_a  = 2'd0;
        alu_src_b  = 2'd0;
        alu_op     = 4'b0000;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 2'd0;
        branch     = 1'b0;
        jump       = 1'b0;
        jalr       = 1'b0;
        ecall      = 1'b0;
        ebreak     = 1'b0;
        mret       = 1'b0;
        sret       = 1'b0;
        csr_en     = 1'b0;
        csr_op     = 2'b00;
        csr_imm_sel = 1'b0;
        imm_out    = 64'b0;

        case (opcode)
            OP_LUI: begin
                reg_write  = 1'b1;
                mem_to_reg = 2'd3; 
                imm_out    = imm_u;
            end
            OP_AUIPC: begin
                reg_write  = 1'b1;
                alu_src_a  = 2'd1; 
                alu_src_b  = 2'd1; 
                imm_out    = imm_u;
                alu_op     = 4'b0000; 
            end
            OP_JAL: begin
                reg_write  = 1'b1;
                jump       = 1'b1;
                mem_to_reg = 2'd2; 
                imm_out    = imm_j;
            end
            OP_JALR: begin
                reg_write  = 1'b1;
                jalr       = 1'b1;
                mem_to_reg = 2'd2; 
                imm_out    = imm_i;
            end
            OP_BRANCH: begin
                branch     = 1'b1;
                imm_out    = imm_b;
                alu_op     = 4'b1000; 
            end
            OP_LOAD: begin
                reg_write  = 1'b1;
                alu_src_b  = 2'd1;
                mem_read   = 1'b1;
                mem_to_reg = 2'd1; 
                imm_out    = imm_i;
                alu_op     = 4'b0000; 
            end
            OP_STORE: begin
                mem_write  = 1'b1;
                alu_src_b  = 2'd1;
                imm_out    = imm_s;
                alu_op     = 4'b0000; 
            end
            OP_IMM: begin
                reg_write  = 1'b1;
                alu_src_b  = 2'd1;
                imm_out    = imm_i;
                case (funct3)
                    3'b000: alu_op = 4'b0000; 
                    3'b010: alu_op = 4'b0010; 
                    3'b011: alu_op = 4'b0011; 
                    3'b100: alu_op = 4'b0100; 
                    3'b110: alu_op = 4'b0110; 
                    3'b111: alu_op = 4'b0111; 
                    3'b001: alu_op = 4'b0001; 
                    3'b101: alu_op = (funct7[5]) ? 4'b1101 : 4'b0101; 
                endcase
            end
            OP_OP: begin
                reg_write  = 1'b1;
                alu_src_b  = 2'd0; 
                case (funct3)
                    3'b000: alu_op = (funct7[5]) ? 4'b1000 : 4'b0000; 
                    3'b001: alu_op = 4'b0001; 
                    3'b010: alu_op = 4'b0010; 
                    3'b011: alu_op = 4'b0011; 
                    3'b100: alu_op = 4'b0100; 
                    3'b101: alu_op = (funct7[5]) ? 4'b1101 : 4'b0101; 
                    3'b110: alu_op = 4'b0110; 
                    3'b111: alu_op = 4'b0111; 
                endcase
            end
            OP_SYSTEM: begin
                if (funct3 == 3'b000) begin
                    case (imm_i[11:0])
                        12'h000: ecall = 1'b1;
                        12'h001: ebreak = 1'b1;
                        12'h302: mret = 1'b1;
                        12'h102: sret = 1'b1;
                    endcase
                end else begin
                    reg_write = 1'b1;
                    csr_en    = 1'b1;
                    case (funct3)
                        3'b001: begin csr_op = 2'b01; csr_imm_sel = 1'b0; end 
                        3'b010: begin csr_op = 2'b10; csr_imm_sel = 1'b0; end 
                        3'b011: begin csr_op = 2'b11; csr_imm_sel = 1'b0; end 
                        3'b101: begin csr_op = 2'b01; csr_imm_sel = 1'b1; end 
                        3'b110: begin csr_op = 2'b10; csr_imm_sel = 1'b1; end 
                        3'b111: begin csr_op = 2'b11; csr_imm_sel = 1'b1; end 
                        default: csr_en = 1'b0;
                    endcase
                end
            end
        endcase
    end
endmodule

