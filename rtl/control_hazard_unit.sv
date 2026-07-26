`default_nettype none

module control_hazard_unit (
    input  wire branch_en_ex, 
    input  wire trap_en_ex,   
    input  wire trap_en_mem,  
    
    
    output logic flush_if,
    output logic flush_id,
    output logic flush_ex
);

    always_comb begin
        flush_if = 1'b0;
        flush_id = 1'b0;
        flush_ex = 1'b0;
        
        if (trap_en_mem) begin
            
            
            flush_if = 1'b1;
            flush_id = 1'b1;
            flush_ex = 1'b1;
        end else if (branch_en_ex || trap_en_ex) begin
            
            flush_if = 1'b1;
            flush_id = 1'b1;
        end
    end

endmodule

