module keyboard_ctl (
    input  logic clk,
    input  logic rst,
    output logic key_space,
    output logic key_right,
    output logic key_left,
    input logic ps2_clk,
    input logic ps2_data
);

timeunit 1ns;
timeprecision 1ps;

logic [15:0] keycode;
logic f_EOT;



PS2Receiver u_ps2_receiver (
    .clk(clk),
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),
    .keycode(keycode),
    .oflag(f_EOT)
);

always_comb begin

        if(keycode[15:8] == 8'hF0) begin
                 key_space = 1'b0;
                 key_right = 1'b0;
                 key_left = 1'b0;
        end
        else begin
            if(keycode[7:0] === 8'h29) begin
                key_space = 1'b1; 
            end else begin
                key_space= 1'b0; 
            end
            if(keycode[7:0] === 8'h23) begin
                key_right = 1'b1; 
            end else begin
                key_right = 1'b0; 
            end
            if(keycode[7:0] === 8'h1C) begin
                key_left = 1'b1; 
            end else begin
                key_left = 1'b0; 
            end

        end
end

endmodule