`default_nettype none

module hazard_unit (
    input  wire [4:0] rs1_id,
    input  wire [4:0] rs2_id,
    
    input  wire       mem_read_ex,
    input  wire [4:0] rd_ex,
    
    
    output logic      stall_if,
    output logic      stall_id,
    output logic      flush_ex
);

    always_comb begin
        
        stall_if = 1'b0;
        stall_id = 1'b0;
        flush_ex = 1'b0;
        
        
        if (mem_read_ex && ((rd_ex == rs1_id) || (rd_ex == rs2_id)) && (rd_ex != 5'b0)) begin
            
            stall_if = 1'b1;
            stall_id = 1'b1;
            flush_ex = 1'b1;
        end
    end

endmodule

