`default_nettype none

module lsu (
    input  wire [63:0] addr,
    input  wire [63:0] wdata_in,
    input  wire [63:0] rdata_in,
    input  wire [2:0]  funct3,
    input  wire        mem_read,
    input  wire        mem_write,
    
    output logic [7:0]  mem_wmask,
    output logic [63:0] mem_wdata,
    output logic [63:0] rdata_out
);

    
    wire [2:0] offset = addr[2:0];

    
    always_comb begin
        mem_wmask = 8'b0;
        mem_wdata = 64'b0;
        
        if (mem_write) begin
            case (funct3)
                3'b000: begin 
                    mem_wmask = 8'b1 << offset;
                    mem_wdata = (wdata_in & 64'hFF) << (offset * 8);
                end
                3'b001: begin 
                    mem_wmask = 8'b11 << offset;
                    mem_wdata = (wdata_in & 64'hFFFF) << (offset * 8);
                end
                3'b010: begin 
                    mem_wmask = 8'b1111 << offset;
                    mem_wdata = (wdata_in & 64'hFFFF_FFFF) << (offset * 8);
                end
                3'b011: begin 
                    mem_wmask = 8'b1111_1111;
                    mem_wdata = wdata_in;
                end
                default: begin
                    mem_wmask = 8'b0;
                    mem_wdata = 64'b0;
                end
            endcase
        end
    end

    
    logic [63:0] shifted_rdata;
    always_comb begin
        shifted_rdata = rdata_in >> (offset * 8);
        rdata_out = 64'b0;
        
        if (mem_read) begin
            case (funct3)
                3'b000: rdata_out = {{56{shifted_rdata[7]}}, shifted_rdata[7:0]};        
                3'b001: rdata_out = {{48{shifted_rdata[15]}}, shifted_rdata[15:0]};      
                3'b010: rdata_out = {{32{shifted_rdata[31]}}, shifted_rdata[31:0]};      
                3'b011: rdata_out = shifted_rdata;                                       
                3'b100: rdata_out = {56'b0, shifted_rdata[7:0]};                         
                3'b101: rdata_out = {48'b0, shifted_rdata[15:0]};                        
                3'b110: rdata_out = {32'b0, shifted_rdata[31:0]};                        
                default: rdata_out = 64'b0;
            endcase
        end
    end

endmodule

