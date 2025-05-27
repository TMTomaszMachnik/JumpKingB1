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


PS2Receiver u_ps2_receiver (
    .clk(clk),
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
    key_space_nxt = key_space;
    key_right_nxt = key_right;
    key_left_nxt = key_left;
    keyboard_buf_nxt = keycode;


    if (f_EOT) begin

        if(keyboard_buf[15:8] == 8'hF0) begin
            keyboard_buf_nxt = '0;
        end
        else begin
        case (keyboard_buf[7:0])
            8'h29: key_space_nxt = 1'b1; 
            8'h23: key_right_nxt = 1'b1; 
            8'h1C: key_left_nxt = 1'b1;
            default: begin
                key_space_nxt = '0;
                key_right_nxt = '0;
                key_left_nxt = '0;
            end
        endcase
        end
    end
end

endmodule