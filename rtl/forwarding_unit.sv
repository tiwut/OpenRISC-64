`default_nettype none

module forwarding_unit (
    input  wire [4:0] rs1_ex,
    input  wire [4:0] rs2_ex,
    
    input  wire [4:0] rd_mem,
    input  wire       reg_write_mem,
    
    input  wire [4:0] rd_wb,
    input  wire       reg_write_wb,
    
    
    
    
    output logic [1:0] forward_a,
    output logic [1:0] forward_b
);

    always_comb begin
        
        forward_a = 2'b00;
        forward_b = 2'b00;

        
        if (reg_write_mem && (rd_mem != 5'b0) && (rd_mem == rs1_ex)) begin
            
            forward_a = 2'b10;
        end else if (reg_write_wb && (rd_wb != 5'b0) && (rd_wb == rs1_ex)) begin
            
            forward_a = 2'b01;
        end

        
        if (reg_write_mem && (rd_mem != 5'b0) && (rd_mem == rs2_ex)) begin
            
            forward_b = 2'b10;
        end else if (reg_write_wb && (rd_wb != 5'b0) && (rd_wb == rs2_ex)) begin
            
            forward_b = 2'b01;
        end
    end

endmodule

