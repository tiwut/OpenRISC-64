`default_nettype none

module csr (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [11:0] csr_addr,
    
    
    input  wire [63:0] wdata,
    input  wire [1:0]  csr_op, 
    input  wire        csr_en,
    output logic [63:0] rdata,
    
    
    input  wire        trap,
    input  wire        mret,
    input  wire        sret,
    input  wire [63:0] epc_in,
    input  wire [63:0] cause_in,
    input  wire [63:0] tval_in,
    output logic [63:0] trap_vector,
    output logic [63:0] epc_out,
    
    
    input  wire        timer_irq,
    output logic       interrupt_trap, 
    
    
    output logic [1:0] priv_mode,
    
    
    output logic [63:0] satp
);

    
    reg [63:0] mstatus, mepc, mcause, mtval, mtvec;
    reg [63:0] sstatus, sepc, scause, stval, stvec;
    reg [63:0] mscratch, sscratch;
    reg [63:0] mie, mip;
    reg [63:0] reg_satp;
    
    assign satp = reg_satp;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            priv_mode <= 2'b11; 
            mstatus   <= 64'b0;
            mtvec     <= 64'b0; 
            mie       <= 64'b0;
            mip       <= 64'b0;
            reg_satp  <= 64'b0;
        end else begin
            
            
            if (timer_irq) mip[7] <= 1'b1;
            else mip[7] <= 1'b0;
            
            
            if (csr_en && !trap) begin 
                logic [63:0] next_val;
                case (csr_op)
                    2'b01: next_val = wdata; 
                    2'b10: next_val = rdata | wdata; 
                    2'b11: next_val = rdata & ~wdata; 
                    default: next_val = rdata;
                endcase
                
                case (csr_addr)
                    12'h300: mstatus  <= next_val;
                    12'h304: mie      <= next_val;
                    12'h305: mtvec    <= next_val;
                    12'h340: mscratch <= next_val;
                    12'h341: mepc     <= next_val;
                    12'h342: mcause   <= next_val;
                    12'h343: mtval    <= next_val;
                    12'h344: mip      <= next_val;
                    12'h100: sstatus  <= next_val;
                    12'h105: stvec    <= next_val;
                    12'h140: sscratch <= next_val;
                    12'h141: sepc     <= next_val;
                    12'h142: scause   <= next_val;
                    12'h143: stval    <= next_val;
                    12'h180: reg_satp <= next_val;
                endcase
            end
            
            
            if (trap) begin
                mepc      <= epc_in;
                mcause    <= cause_in;
                mtval     <= tval_in;
                mstatus[12:11] <= priv_mode; 
                mstatus[7]     <= mstatus[3]; 
                mstatus[3]     <= 1'b0; 
                priv_mode      <= 2'b11;
            end else if (mret) begin
                priv_mode      <= mstatus[12:11]; 
                mstatus[3]     <= mstatus[7]; 
                mstatus[7]     <= 1'b1; 
                mstatus[12:11] <= 2'b00; 
            end
        end
    end

    always_comb begin
        case (csr_addr)
            12'h300: rdata = mstatus;
            12'h304: rdata = mie;
            12'h305: rdata = mtvec;
            12'h340: rdata = mscratch;
            12'h341: rdata = mepc;
            12'h342: rdata = mcause;
            12'h343: rdata = mtval;
            12'h344: rdata = mip;
            12'h100: rdata = sstatus;
            12'h105: rdata = stvec;
            12'h140: rdata = sscratch;
            12'h141: rdata = sepc;
            12'h142: rdata = scause;
            12'h143: rdata = stval;
            12'h180: rdata = reg_satp;
            default: rdata = 64'b0;
        endcase
    end
    
    
    
    wire global_interrupt_enable = (priv_mode == 2'b11) ? mstatus[3] : 1'b1;
    
    wire timer_interrupt_pending = global_interrupt_enable && mie[7] && mip[7];
    
    assign interrupt_trap = timer_interrupt_pending;
    
    assign trap_vector = mtvec;
    assign epc_out = (mret) ? mepc : sepc;

endmodule

