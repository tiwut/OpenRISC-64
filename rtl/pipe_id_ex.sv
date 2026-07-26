`default_nettype none

module pipe_id_ex (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        flush,
    input  wire        stall,
    
    
    input  wire [63:0] pc_in,
    input  wire [63:0] rdata1_in,
    input  wire [63:0] rdata2_in,
    input  wire [63:0] imm_out_in,
    
    
    input  wire [4:0]  rs1_in,
    input  wire [4:0]  rs2_in,
    input  wire [4:0]  rd_in,
    
    
    input  wire        reg_write_in,
    input  wire [1:0]  alu_src_a_in,
    input  wire [1:0]  alu_src_b_in,
    input  wire [3:0]  alu_op_in,
    input  wire        mem_read_in,
    input  wire        mem_write_in,
    input  wire [1:0]  mem_to_reg_in,
    input  wire        branch_in,
    input  wire        jump_in,
    input  wire        jalr_in,
    input  wire        ecall_in,
    input  wire        ebreak_in,
    input  wire        mret_in,
    input  wire        sret_in,
    input  wire        csr_en_in,
    input  wire [1:0]  csr_op_in,
    input  wire        csr_imm_sel_in,
    input  wire [2:0]  funct3_in,
    input  wire        inst_page_fault_in,
    
    
    output logic [63:0] pc_out,
    output logic [63:0] rdata1_out,
    output logic [63:0] rdata2_out,
    output logic [63:0] imm_out_out,
    
    output logic [4:0]  rs1_out,
    output logic [4:0]  rs2_out,
    output logic [4:0]  rd_out,
    
    output logic        reg_write_out,
    output logic [1:0]  alu_src_a_out,
    output logic [1:0]  alu_src_b_out,
    output logic [3:0]  alu_op_out,
    output logic        mem_read_out,
    output logic        mem_write_out,
    output logic [1:0]  mem_to_reg_out,
    output logic        branch_out,
    output logic        jump_out,
    output logic        jalr_out,
    output logic        ecall_out,
    output logic        ebreak_out,
    output logic        mret_out,
    output logic        sret_out,
    output logic        csr_en_out,
    output logic [1:0]  csr_op_out,
    output logic        csr_imm_sel_out,
    output logic [2:0]  funct3_out,
    output logic        inst_page_fault_out
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_out         <= 64'b0;
            rdata1_out     <= 64'b0;
            rdata2_out     <= 64'b0;
            imm_out_out    <= 64'b0;
            rs1_out        <= 5'b0;
            rs2_out        <= 5'b0;
            rd_out         <= 5'b0;
            reg_write_out  <= 1'b0;
            alu_src_a_out  <= 2'b0;
            alu_src_b_out  <= 2'b0;
            alu_op_out     <= 4'b0;
            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;
            mem_to_reg_out <= 2'b0;
            branch_out     <= 1'b0;
            jump_out       <= 1'b0;
            jalr_out       <= 1'b0;
            ecall_out      <= 1'b0;
            ebreak_out     <= 1'b0;
            mret_out       <= 1'b0;
            sret_out       <= 1'b0;
            csr_en_out     <= 1'b0;
            csr_op_out     <= 2'b0;
            csr_imm_sel_out <= 1'b0;
            funct3_out     <= 3'b0;
            inst_page_fault_out <= 1'b0;
        end else if (flush) begin
            pc_out         <= 64'b0;
            rdata1_out     <= 64'b0;
            rdata2_out     <= 64'b0;
            imm_out_out    <= 64'b0;
            rs1_out        <= 5'b0;
            rs2_out        <= 5'b0;
            rd_out         <= 5'b0;
            reg_write_out  <= 1'b0;
            alu_src_a_out  <= 2'b0;
            alu_src_b_out  <= 2'b0;
            alu_op_out     <= 4'b0;
            mem_read_out   <= 1'b0;
            mem_write_out  <= 1'b0;
            mem_to_reg_out <= 2'b0;
            branch_out     <= 1'b0;
            jump_out       <= 1'b0;
            jalr_out       <= 1'b0;
            ecall_out      <= 1'b0;
            ebreak_out     <= 1'b0;
            mret_out       <= 1'b0;
            sret_out       <= 1'b0;
            csr_en_out     <= 1'b0;
            csr_op_out     <= 2'b0;
            csr_imm_sel_out <= 1'b0;
            funct3_out     <= 3'b0;
            inst_page_fault_out <= 1'b0;
        end else if (!stall) begin
            pc_out         <= pc_in;
            rdata1_out     <= rdata1_in;
            rdata2_out     <= rdata2_in;
            imm_out_out    <= imm_out_in;
            rs1_out        <= rs1_in;
            rs2_out        <= rs2_in;
            rd_out         <= rd_in;
            reg_write_out  <= reg_write_in;
            alu_src_a_out  <= alu_src_a_in;
            alu_src_b_out  <= alu_src_b_in;
            alu_op_out     <= alu_op_in;
            mem_read_out   <= mem_read_in;
            mem_write_out  <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            branch_out     <= branch_in;
            jump_out       <= jump_in;
            jalr_out       <= jalr_in;
            ecall_out      <= ecall_in;
            ebreak_out     <= ebreak_in;
            mret_out       <= mret_in;
            sret_out       <= sret_in;
            csr_en_out     <= csr_en_in;
            csr_op_out     <= csr_op_in;
            csr_imm_sel_out <= csr_imm_sel_in;
            funct3_out     <= funct3_in;
            inst_page_fault_out <= inst_page_fault_in;
        end
    end
endmodule

