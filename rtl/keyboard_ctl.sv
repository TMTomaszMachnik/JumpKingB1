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
logic [15:0] keyboard_buf;
logic [15:0] keyboard_buf_nxt;
logic         CLK50MHZ=0;

always @(posedge(clk))begin
    CLK50MHZ<=~CLK50MHZ;
end

PS2Receiver u_ps2_receiver (
    .clk(CLK50MHZ),
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),
    .keycode(keycode),
    .oflag(f_EOT)
);


logic key_space_nxt;
logic key_right_nxt;
logic key_left_nxt;


always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        key_space <= 1'b0;
        key_right <= 1'b0;
        key_left <= 1'b0;
        keyboard_buf <= 16'h0000;
    end else begin
        key_space <= key_space_nxt;
        key_right <= key_right_nxt;
        key_left <= key_left_nxt;
        keyboard_buf <= keyboard_buf_nxt;
    end
end

always_comb begin
    if (f_EOT) begin
        case (keycode)
            16'h29: key_space_nxt = 1'b1; 
            16'hF029: key_space_nxt = 1'b0;
            16'h74: key_right_nxt = 1'b1; 
            16'hF074: key_right_nxt = 1'b0; 
            16'h6B: key_left_nxt = 1'b1; 
            16'hF06B: key_left_nxt = 1'b0; 
            default: ; 
        endcase
    end else begin
        key_space_nxt = 1'b0;
        key_left_nxt = 1'b0;
        key_right_nxt = 1'b0;
    end
    keyboard_buf_nxt = keycode;
end

endmodule