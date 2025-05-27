module image_rom (
    input  logic clk,
    input  logic [1:0] character_state, 
    input  logic [11:0] address,      
    output logic [11:0] rgb           
);

    /**
     * Local variables and signals
     */
    reg [11:0] micro_normal [0:3071];   
    reg [11:0] micro_curled [0:3071];  
    reg [11:0] micro_jump   [0:3071]; 


    initial begin
        $readmemh("../Graphics/micro.data", micro_normal);
        $readmemh("../Graphics/micro_curled.data", micro_curled);
        $readmemh("../Graphics/micro_jump.data", micro_jump);
    end

    /**
     * Character frame selection logic
     */
    always_ff @(posedge clk) begin
        case (character_state)
            2'b00:   rgb <= micro_normal[address];  
            2'b01:   rgb <= micro_curled[address];  
            2'b10:   rgb <= micro_jump[address];    
            default: rgb <= micro_normal[address]; 
        endcase
    end

endmodule
