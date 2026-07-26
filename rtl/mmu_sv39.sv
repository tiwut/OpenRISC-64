`default_nettype none

module mmu_sv39 (
    input  wire        clk,
    input  wire        rst_n,
    
    
    input  wire [63:0] vaddr,
    input  wire        req_en,
    input  wire        req_write,
    input  wire [1:0]  priv_mode,
    input  wire [63:0] satp,
    
    output logic [55:0] paddr,
    output logic        page_fault,
    output logic        ready,
    
    
    output logic [63:0] mem_addr,
    output logic        mem_req,
    input  wire  [63:0] mem_rdata,
    input  wire         mem_ready
);

    wire [3:0]  mode = satp[63:60];
    wire [43:0] ppn  = satp[43:0];
    
    wire [8:0] vpn [2:0];
    assign vpn[2] = vaddr[38:30];
    assign vpn[1] = vaddr[29:21];
    assign vpn[0] = vaddr[20:12];
    
    wire [11:0] page_offset = vaddr[11:0];
    
    typedef enum logic [2:0] {
        IDLE,
        L2_EVAL,
        L1_EVAL,
        L0_EVAL,
        DONE
    } state_t;
    
    state_t state, next_state;
    
    logic [43:0] walk_ppn;
    logic [43:0] next_walk_ppn;
    logic [2:0]  leaf_level;
    logic [2:0]  next_leaf_level;
    
    logic        pf_reg, next_pf_reg;
    
    wire bypass = (mode == 4'd0 || priv_mode == 2'b11); 
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE;
            walk_ppn    <= 44'b0;
            pf_reg      <= 1'b0;
            leaf_level  <= 3'd0;
        end else begin
            state       <= next_state;
            walk_ppn    <= next_walk_ppn;
            pf_reg      <= next_pf_reg;
            leaf_level  <= next_leaf_level;
        end
    end
    
    
    always_comb begin
        next_state      = state;
        next_walk_ppn   = walk_ppn;
        next_pf_reg     = pf_reg;
        next_leaf_level = leaf_level;
        
        mem_req  = 1'b0;
        mem_addr = 64'b0;
        
        ready      = 1'b0;
        page_fault = 1'b0;
        paddr      = 56'b0;
        
        if (req_en) begin
            if (bypass) begin
                ready      = 1'b1;
                page_fault = 1'b0;
                paddr      = vaddr[55:0];
            end else begin
                case (state)
                    IDLE: begin
                        next_state    = L2_EVAL;
                        next_walk_ppn = ppn;
                        next_pf_reg   = 1'b0;
                        next_leaf_level = 3'd0;
                    end
                    L2_EVAL: begin
                        mem_req  = 1'b1;
                        mem_addr = {8'b0, walk_ppn, 12'b0} + {50'b0, vpn[2], 3'b0};
                        
                        if (mem_ready) begin
                            if ((mem_rdata[0] == 0) || (mem_rdata[2:1] == 2'b10)) begin 
                                next_state  = DONE;
                                next_pf_reg = 1'b1;
                            end else if (mem_rdata[3:1] == 3'b000) begin 
                                next_state    = L1_EVAL;
                                next_walk_ppn = mem_rdata[53:10];
                            end else begin 
                                next_state      = DONE;
                                next_pf_reg     = 1'b0; 
                                next_walk_ppn   = mem_rdata[53:10];
                                next_leaf_level = 3'd2;
                            end
                        end
                    end
                    L1_EVAL: begin
                        mem_req  = 1'b1;
                        mem_addr = {8'b0, walk_ppn, 12'b0} + {50'b0, vpn[1], 3'b0};
                        
                        if (mem_ready) begin
                            if ((mem_rdata[0] == 0) || (mem_rdata[2:1] == 2'b10)) begin 
                                next_state  = DONE;
                                next_pf_reg = 1'b1;
                            end else if (mem_rdata[3:1] == 3'b000) begin 
                                next_state    = L0_EVAL;
                                next_walk_ppn = mem_rdata[53:10];
                            end else begin 
                                next_state      = DONE;
                                next_pf_reg     = 1'b0;
                                next_walk_ppn   = mem_rdata[53:10];
                                next_leaf_level = 3'd1;
                            end
                        end
                    end
                    L0_EVAL: begin
                        mem_req  = 1'b1;
                        mem_addr = {8'b0, walk_ppn, 12'b0} + {50'b0, vpn[0], 3'b0};
                        
                        if (mem_ready) begin
                            if ((mem_rdata[0] == 0) || (mem_rdata[2:1] == 2'b10) || (mem_rdata[3:1] == 3'b000)) begin
                                next_state  = DONE;
                                next_pf_reg = 1'b1;
                            end else begin 
                                next_state      = DONE;
                                next_pf_reg     = 1'b0;
                                next_walk_ppn   = mem_rdata[53:10];
                                next_leaf_level = 3'd0;
                            end
                        end
                    end
                    DONE: begin
                        ready = 1'b1;
                        page_fault = pf_reg;
                        
                        if (leaf_level == 3'd2) begin
                            paddr = {walk_ppn[43:18], vaddr[29:0]}; 
                        end else if (leaf_level == 3'd1) begin
                            paddr = {walk_ppn[43:9], vaddr[20:0]}; 
                        end else begin
                            paddr = {walk_ppn, page_offset}; 
                        end
                        
                        
                    end
                endcase
            end
        end else begin
            next_state = IDLE;
        end
    end

endmodule

