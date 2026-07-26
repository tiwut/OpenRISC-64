`default_nettype none

module core (
    input  wire clk,
    input  wire rst_n,
    input  wire timer_irq
);

    
    
    
    wire        mmu_stall;
    wire        stall_if_hdu;
    wire        stall_if = stall_if_hdu | mmu_stall;
    wire        flush_if_chu;
    wire        flush_if = flush_if_chu; 
    
    wire [63:0] pc_if;
    wire [31:0] inst_if;
    
    wire        branch_en_ex; 
    wire [63:0] branch_target_ex;
    
    wire        trap_en_ex;
    wire        trap_en_mem;
    wire [63:0] trap_vector;
    wire [63:0] epc_out;
    
    wire ctrl_mret_ex;
    wire ctrl_sret_ex;
    wire ctrl_ecall_ex;
    wire ctrl_ebreak_ex;

    wire exception_ex = ctrl_ecall_ex | ctrl_ebreak_ex | interrupt_trap | inst_page_fault_ex;
    wire return_ex    = ctrl_mret_ex | ctrl_sret_ex;
    assign trap_en_ex = exception_ex | return_ex;

    wire [63:0] pc_next_target = trap_en_mem ? trap_vector :
                                 return_ex   ? epc_out : 
                                 exception_ex? trap_vector : 
                                 branch_target_ex;
    wire pc_redirect_en = branch_en_ex | trap_en_ex | trap_en_mem;

    pc pc_inst (
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall_if),
        .branch_en(pc_redirect_en),
        .branch_target(pc_next_target),
        .pc_out(pc_if)
    );

    wire [63:0] mem_rdata_mem; 
    wire [63:0] mem_addr_mem;
    wire [63:0] mem_wdata_mem;
    wire [7:0]  mem_wmask_mem;
    wire        mem_we_mem;
    wire        mem_re_mem;

    wire [55:0] paddr_if;
    wire        page_fault_if;
    wire        immu_ready;
    wire [63:0] ptw0_addr;
    wire [63:0] ptw0_rdata;
    wire        ptw0_req;
    
    wire [55:0] paddr_mem;
    wire        page_fault_mem;
    wire        dmmu_ready;
    wire [63:0] ptw1_addr;
    wire [63:0] ptw1_rdata;
    wire        ptw1_req;

    assign mmu_stall = (~immu_ready && !flush_if) | (~dmmu_ready && (ctrl_mem_read_mem | ctrl_mem_write_mem));

    memory #(
        .SIZE_BYTES(8192),
        .INIT_FILE("firmware.hex")
    ) memory_inst (
        .clk(clk),
        .if_addr({8'b0, paddr_if}),
        .if_inst(inst_if),
        .mem_addr({8'b0, paddr_mem} & ~64'h7),
        .mem_wdata(mem_wdata_mem),
        .mem_wmask(mem_wmask_mem),
        .mem_we(mem_we_mem),
        .mem_re(mem_re_mem),
        .mem_rdata(mem_rdata_mem),
        .ptw0_addr(ptw0_addr),
        .ptw0_rdata(ptw0_rdata),
        .ptw1_addr(ptw1_addr),
        .ptw1_rdata(ptw1_rdata)
    );

    
    
    
    wire flush_id_chu;
    wire flush_ex_chu;
    wire interrupt_trap;
    
    control_hazard_unit chu_inst (
        .branch_en_ex(branch_en_ex),
        .trap_en_ex(trap_en_ex),
        .trap_en_mem(trap_en_mem),
        .flush_if(flush_if_chu),
        .flush_id(flush_id_chu),
        .flush_ex(flush_ex_chu)
    );

    
    
    
    wire stall_id_hdu; 
    wire stall_id = stall_id_hdu | mmu_stall;
    
    wire [63:0] pc_id;
    wire [31:0] inst_id;
    wire        inst_page_fault_id;

    pipe_if_id if_id_reg (
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush_if_chu), 
        .stall(stall_id),
        .pc_in(pc_if),
        .inst_in(inst_if),
        .inst_page_fault_in(page_fault_if),
        .pc_out(pc_id),
        .inst_out(inst_id),
        .inst_page_fault_out(inst_page_fault_id)
    );

    
    
    
    wire [6:0]  opcode_id;
    wire [4:0]  rd_id, rs1_id, rs2_id;
    wire [2:0]  funct3_id;
    wire [6:0]  funct7_id;
    wire [63:0] imm_i_id, imm_s_id, imm_b_id, imm_u_id, imm_j_id;

    decoder decoder_inst (
        .inst(inst_id),
        .opcode(opcode_id),
        .rd(rd_id),
        .funct3(funct3_id),
        .rs1(rs1_id),
        .rs2(rs2_id),
        .funct7(funct7_id),
        .imm_i(imm_i_id),
        .imm_s(imm_s_id),
        .imm_b(imm_b_id),
        .imm_u(imm_u_id),
        .imm_j(imm_j_id)
    );

    wire [63:0] rdata1_id, rdata2_id;
    logic [63:0] wdata_wb; 
    wire [4:0]  rd_wb;    
    wire        we_wb;    

    regfile regfile_inst (
        .clk(clk),
        .rs1(rs1_id),
        .rs2(rs2_id),
        .rd(rd_wb),
        .wdata(wdata_wb),
        .we(we_wb),
        .rdata1(rdata1_id),
        .rdata2(rdata2_id)
    );

    wire       ctrl_reg_write_id;
    wire [1:0] ctrl_alu_src_a_id;
    wire [1:0] ctrl_alu_src_b_id;
    wire [3:0] ctrl_alu_op_id;
    wire       ctrl_mem_read_id;
    wire       ctrl_mem_write_id;
    wire [1:0] ctrl_mem_to_reg_id;
    wire       ctrl_branch_id;
    wire       ctrl_jump_id;
    wire       ctrl_jalr_id;
    wire       ctrl_ecall_id;
    wire       ctrl_ebreak_id;
    wire       ctrl_mret_id;
    wire       ctrl_sret_id;
    wire       ctrl_csr_en_id;
    wire [1:0] ctrl_csr_op_id;
    wire       ctrl_csr_imm_sel_id;
    wire [63:0] ctrl_imm_out_id;

    control control_inst (
        .opcode(opcode_id),
        .funct3(funct3_id),
        .funct7(funct7_id),
        .imm_i(imm_i_id),
        .imm_s(imm_s_id),
        .imm_b(imm_b_id),
        .imm_u(imm_u_id),
        .imm_j(imm_j_id),
        .reg_write(ctrl_reg_write_id),
        .alu_src_a(ctrl_alu_src_a_id),
        .alu_src_b(ctrl_alu_src_b_id),
        .alu_op(ctrl_alu_op_id),
        .mem_read(ctrl_mem_read_id),
        .mem_write(ctrl_mem_write_id),
        .mem_to_reg(ctrl_mem_to_reg_id),
        .branch(ctrl_branch_id),
        .jump(ctrl_jump_id),
        .jalr(ctrl_jalr_id),
        .ecall(ctrl_ecall_id),
        .ebreak(ctrl_ebreak_id),
        .mret(ctrl_mret_id),
        .sret(ctrl_sret_id),
        .csr_en(ctrl_csr_en_id),
        .csr_op(ctrl_csr_op_id),
        .csr_imm_sel(ctrl_csr_imm_sel_id),
        .imm_out(ctrl_imm_out_id)
    );

    
    
    
    wire stall_ex = mmu_stall;
    wire flush_ex_hdu; 
    wire flush_ex = flush_ex_hdu | flush_ex_chu;

    wire [63:0] pc_ex;
    wire [63:0] rdata1_ex;
    wire [63:0] rdata2_ex;
    wire [63:0] imm_out_ex;
    wire [4:0]  rs1_ex, rs2_ex, rd_ex;
    
    wire        ctrl_reg_write_ex;
    wire [1:0]  ctrl_alu_src_a_ex;
    wire [1:0]  ctrl_alu_src_b_ex;
    wire [3:0]  ctrl_alu_op_ex;
    wire        ctrl_mem_read_ex;
    wire        ctrl_mem_write_ex;
    wire [1:0]  ctrl_mem_to_reg_ex;
    wire        ctrl_branch_ex;
    wire        ctrl_jump_ex;
    wire        ctrl_jalr_ex;
    wire        ctrl_csr_en_ex;
    wire [1:0]  ctrl_csr_op_ex;
    wire        ctrl_csr_imm_sel_ex;
    wire [2:0]  funct3_ex;
    wire        inst_page_fault_ex;

    pipe_id_ex id_ex_reg (
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush_ex | flush_id_chu), 
        .stall(stall_ex),
        
        .pc_in(pc_id),
        .rdata1_in(rdata1_id),
        .rdata2_in(rdata2_id),
        .imm_out_in(ctrl_imm_out_id),
        
        .rs1_in(rs1_id),
        .rs2_in(rs2_id),
        .rd_in(rd_id),
        
        .reg_write_in(ctrl_reg_write_id),
        .alu_src_a_in(ctrl_alu_src_a_id),
        .alu_src_b_in(ctrl_alu_src_b_id),
        .alu_op_in(ctrl_alu_op_id),
        .mem_read_in(ctrl_mem_read_id),
        .mem_write_in(ctrl_mem_write_id),
        .mem_to_reg_in(ctrl_mem_to_reg_id),
        .branch_in(ctrl_branch_id),
        .jump_in(ctrl_jump_id),
        .jalr_in(ctrl_jalr_id),
        .ecall_in(ctrl_ecall_id),
        .ebreak_in(ctrl_ebreak_id),
        .mret_in(ctrl_mret_id),
        .sret_in(ctrl_sret_id),
        .csr_en_in(ctrl_csr_en_id),
        .csr_op_in(ctrl_csr_op_id),
        .csr_imm_sel_in(ctrl_csr_imm_sel_id),
        .funct3_in(funct3_id),
        .inst_page_fault_in(inst_page_fault_id),
        
        .pc_out(pc_ex),
        .rdata1_out(rdata1_ex),
        .rdata2_out(rdata2_ex),
        .imm_out_out(imm_out_ex),
        
        .rs1_out(rs1_ex),
        .rs2_out(rs2_ex),
        .rd_out(rd_ex),
        
        .reg_write_out(ctrl_reg_write_ex),
        .alu_src_a_out(ctrl_alu_src_a_ex),
        .alu_src_b_out(ctrl_alu_src_b_ex),
        .alu_op_out(ctrl_alu_op_ex),
        .mem_read_out(ctrl_mem_read_ex),
        .mem_write_out(ctrl_mem_write_ex),
        .mem_to_reg_out(ctrl_mem_to_reg_ex),
        .branch_out(ctrl_branch_ex),
        .jump_out(ctrl_jump_ex),
        .jalr_out(ctrl_jalr_ex),
        .ecall_out(ctrl_ecall_ex),
        .ebreak_out(ctrl_ebreak_ex),
        .mret_out(ctrl_mret_ex),
        .sret_out(ctrl_sret_ex),
        .csr_en_out(ctrl_csr_en_ex),
        .csr_op_out(ctrl_csr_op_ex),
        .csr_imm_sel_out(ctrl_csr_imm_sel_ex),
        .funct3_out(funct3_ex),
        .inst_page_fault_out(inst_page_fault_ex)
    );

    
    hazard_unit hazard_unit_inst (
        .rs1_id(rs1_id),
        .rs2_id(rs2_id),
        .mem_read_ex(ctrl_mem_read_ex),
        .rd_ex(rd_ex),
        .stall_if(stall_if_hdu),
        .stall_id(stall_id_hdu),
        .flush_ex(flush_ex_hdu)
    );

    
    
    
    wire [4:0]  rd_mem;
    wire        ctrl_reg_write_mem;
    wire [1:0]  forward_a;
    wire [1:0]  forward_b;
    logic [63:0] forward_a_val;
    logic [63:0] forward_b_val;
    logic [63:0] ex_mem_forward_val;
    
    wire [1:0] ctrl_mem_to_reg_mem;
    wire [63:0] alu_result_mem;
    wire [63:0] pc_mem;
    wire [63:0] imm_out_mem;
    
    always_comb begin
        case (ctrl_mem_to_reg_mem)
            2'd0: ex_mem_forward_val = alu_result_mem;
            2'd1: ex_mem_forward_val = alu_result_mem; 
            2'd2: ex_mem_forward_val = pc_mem + 64'd4;
            2'd3: ex_mem_forward_val = imm_out_mem;
            default: ex_mem_forward_val = 64'b0;
        endcase
    end

    always_comb begin
        case (forward_a)
            2'b00: forward_a_val = rdata1_ex;
            2'b10: forward_a_val = ex_mem_forward_val;
            2'b01: forward_a_val = wdata_wb;
            default: forward_a_val = rdata1_ex;
        endcase
        
        case (forward_b)
            2'b00: forward_b_val = rdata2_ex;
            2'b10: forward_b_val = ex_mem_forward_val;
            2'b01: forward_b_val = wdata_wb;
            default: forward_b_val = rdata2_ex;
        endcase
    end

    forwarding_unit forwarding_unit_inst (
        .rs1_ex(rs1_ex),
        .rs2_ex(rs2_ex),
        .rd_mem(rd_mem),
        .reg_write_mem(ctrl_reg_write_mem),
        .rd_wb(rd_wb),
        .reg_write_wb(we_wb),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    wire [63:0] alu_a_in, alu_b_in;
    assign alu_a_in = (ctrl_alu_src_a_ex == 2'd1) ? pc_ex : forward_a_val;
    assign alu_b_in = (ctrl_alu_src_b_ex == 2'd1) ? imm_out_ex : forward_b_val;

    wire [63:0] alu_result_ex_raw;
    wire        alu_zero_ex;

    alu alu_inst (
        .a(alu_a_in),
        .b(alu_b_in),
        .alu_op(ctrl_alu_op_ex),
        .result(alu_result_ex_raw),
        .zero(alu_zero_ex)
    );
    
    wire [63:0] alu_result_ex = (ctrl_csr_en_ex) ? csr_rdata : alu_result_ex_raw;

    branch_unit branch_unit_inst (
        .rs1_data(forward_a_val),
        .rs2_data(forward_b_val),
        .pc(pc_ex),
        .imm(imm_out_ex),
        .funct3(funct3_ex),
        .branch(ctrl_branch_ex),
        .jump(ctrl_jump_ex),
        .jalr(ctrl_jalr_ex),
        .branch_en(branch_en_ex),
        .branch_target(branch_target_ex)
    );

    
    
    
    wire stall_mem = mmu_stall;
    wire flush_mem = 1'b0;

    wire [63:0] rdata2_mem;
    
    wire        ctrl_mem_read_mem;
    wire        ctrl_mem_write_mem;
    wire [2:0]  funct3_mem;

    pipe_ex_mem ex_mem_reg (
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush_mem),
        .stall(stall_mem),
        
        .alu_result_in(alu_result_ex),
        .rdata2_in(forward_b_val), 
        .pc_in(pc_ex),
        .imm_out_in(imm_out_ex),
        .rd_in(rd_ex),
        
        .reg_write_in(ctrl_reg_write_ex),
        .mem_read_in(ctrl_mem_read_ex),
        .mem_write_in(ctrl_mem_write_ex),
        .mem_to_reg_in(ctrl_mem_to_reg_ex),
        .funct3_in(funct3_ex),
        
        .alu_result_out(alu_result_mem),
        .rdata2_out(rdata2_mem),
        .pc_out(pc_mem),
        .imm_out_out(imm_out_mem),
        .rd_out(rd_mem),
        
        .reg_write_out(ctrl_reg_write_mem),
        .mem_read_out(ctrl_mem_read_mem),
        .mem_write_out(ctrl_mem_write_mem),
        .mem_to_reg_out(ctrl_mem_to_reg_mem),
        .funct3_out(funct3_mem)
    );

    
    
    
    wire [63:0] lsu_rdata_out_mem;
    
    assign mem_addr_mem = alu_result_mem;
    assign mem_we_mem   = ctrl_mem_write_mem;
    assign mem_re_mem   = ctrl_mem_read_mem;

    lsu lsu_inst (
        .addr(alu_result_mem),
        .wdata_in(rdata2_mem),
        .rdata_in(mem_rdata_mem),
        .funct3(funct3_mem),
        .mem_read(ctrl_mem_read_mem),
        .mem_write(ctrl_mem_write_mem),
        .mem_wmask(mem_wmask_mem),
        .mem_wdata(mem_wdata_mem),
        .rdata_out(lsu_rdata_out_mem)
    );

    
    
    
    wire stall_wb = mmu_stall;
    wire flush_wb = 1'b0;

    wire [63:0] alu_result_wb;
    wire [63:0] lsu_rdata_wb;
    wire [63:0] pc_wb;
    wire [63:0] imm_out_wb;
    
    wire [1:0]  ctrl_mem_to_reg_wb;

    pipe_mem_wb mem_wb_reg (
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush_wb),
        .stall(stall_wb),
        
        .alu_result_in(alu_result_mem),
        .lsu_rdata_in(lsu_rdata_out_mem),
        .pc_in(pc_mem),
        .imm_out_in(imm_out_mem),
        .rd_in(rd_mem),
        
        .reg_write_in(ctrl_reg_write_mem),
        .mem_to_reg_in(ctrl_mem_to_reg_mem),
        
        .alu_result_out(alu_result_wb),
        .lsu_rdata_out(lsu_rdata_wb),
        .pc_out(pc_wb),
        .imm_out_out(imm_out_wb),
        .rd_out(rd_wb),
        
        .reg_write_out(we_wb),
        .mem_to_reg_out(ctrl_mem_to_reg_wb)
    );

    
    
    
    always_comb begin
        case (ctrl_mem_to_reg_wb)
            2'd0: wdata_wb = alu_result_wb;
            2'd1: wdata_wb = lsu_rdata_wb;
            2'd2: wdata_wb = pc_wb + 64'd4;
            2'd3: wdata_wb = imm_out_wb;
            default: wdata_wb = 64'b0;
        endcase
    end

    logic [11:0] csr_addr = 12'b0;
    logic [63:0] csr_wdata_reg = 64'b0;
    wire [63:0]  csr_rdata;
    wire [1:0]   priv_mode;
    wire [63:0]  satp;
    
    assign trap_en_mem = page_fault_mem & (ctrl_mem_read_mem | ctrl_mem_write_mem);
    
    wire [63:0] cause_in = trap_en_mem ? (ctrl_mem_write_mem ? 64'd15 : 64'd13) :
                           interrupt_trap ? 64'h8000000000000007 :
                           inst_page_fault_ex ? 64'd12 :
                           ctrl_ecall_ex ? (priv_mode == 2'b11 ? 64'd11 : (priv_mode == 2'b01 ? 64'd9 : 64'd8)) :
                           ctrl_ebreak_ex ? 64'd3 : 64'd0;
                           
    wire [63:0] epc_in = trap_en_mem ? pc_mem : pc_ex;
    wire [63:0] tval_in = trap_en_mem ? alu_result_mem : (inst_page_fault_ex ? pc_ex : 64'b0);
                           
    wire [63:0] csr_wdata = (ctrl_csr_imm_sel_ex) ? {59'b0, rs1_ex} : forward_a_val;

    csr csr_inst (
        .clk(clk),
        .rst_n(rst_n),
        .csr_addr(imm_out_ex[11:0]),
        .wdata(csr_wdata),
        .csr_op(ctrl_csr_op_ex),
        .csr_en(ctrl_csr_en_ex),
        .rdata(csr_rdata),
        .trap(exception_ex | trap_en_mem),
        .mret(ctrl_mret_ex),
        .sret(ctrl_sret_ex),
        .epc_in(epc_in),
        .cause_in(cause_in),
        .tval_in(tval_in),
        .trap_vector(trap_vector),
        .epc_out(epc_out),
        .timer_irq(timer_irq),
        .interrupt_trap(interrupt_trap),
        .priv_mode(priv_mode),
        .satp(satp)
    );

    mmu_sv39 immu_inst (
        .clk(clk),
        .rst_n(rst_n),
        .vaddr(pc_if), 
        .req_en(!flush_if),
        .req_write(1'b0),
        .priv_mode(priv_mode),
        .satp(satp),
        .paddr(paddr_if),
        .page_fault(page_fault_if),
        .ready(immu_ready),
        .mem_addr(ptw0_addr),
        .mem_req(ptw0_req),
        .mem_rdata(ptw0_rdata),
        .mem_ready(1'b1)
    );
    
    mmu_sv39 dmmu_inst (
        .clk(clk),
        .rst_n(rst_n),
        .vaddr(alu_result_mem), 
        .req_en(ctrl_mem_read_mem | ctrl_mem_write_mem),
        .req_write(ctrl_mem_write_mem),
        .priv_mode(priv_mode),
        .satp(satp),
        .paddr(paddr_mem),
        .page_fault(page_fault_mem),
        .ready(dmmu_ready),
        .mem_addr(ptw1_addr),
        .mem_req(ptw1_req),
        .mem_rdata(ptw1_rdata),
        .mem_ready(1'b1)
    );

endmodule

