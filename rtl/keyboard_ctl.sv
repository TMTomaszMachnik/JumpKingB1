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

logic [15:0] keyboard_data;
logic f_EOT;

PS2Receiver u_ps2_receiver (
    .clk(clk),
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data),
    .keycode(keyboard_data),
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
    end else begin
        key_space <= key_space_nxt;
        key_right <= key_right_nxt;
        key_left <= key_left_nxt;
    end
end

always_comb begin
    if (f_EOT) begin
        case (keyboard_data)
            8'h20: key_space_nxt = 1'b1; 
            8'h23: key_left_nxt = 1'b1; 
            8'h4D: key_right_nxt = 1'b1; 
            default: begin
                key_space_nxt = 1'b0;
                key_left_nxt = 1'b0;
                key_right_nxt = 1'b0;
            end
        endcase
    end else begin
        key_space_nxt = 1'b0;
        key_left_nxt = 1'b0;
        key_right_nxt = 1'b0;
    end
end

endmodule