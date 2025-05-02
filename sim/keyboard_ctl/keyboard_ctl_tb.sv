module keyboard_ctl_tb();

`timescale 1ns / 1ps

localparam CLK_PERIOD = 25; //40Mhz

logic clk, rst;

logic [11:0] x_out;
logic [11:0] y_out;
logic key_space;
logic key_right;
logic key_left;


initial begin
    clk = 1'b0;
    rst = 1'b0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end


initial begin
    rst = 1'b0;
    #(1.25*CLK_PERIOD) rst = 1'b1;
    rst = 1'b1;
    #(2.00*CLK_PERIOD) rst = 1'b0;
end


keyboard_ctl_prog dut_ctrl(
    .clk,
    .rst,
    .key_space(key_space),
    .key_right(key_right),
    .key_left(key_left)
);

draw_rect_ctl dut(
    .clk,
    .rst,
    .key_space(key_space),
    .key_right(key_right),
    .key_left(key_left),
    .value_x(x_out),
    .value_y(y_out)
);

always_comb begin
    $display("Time: %0t | key_space: %b |position_y: %0d | rst: %0d | cycle_counter: %0d | time_passed: %0d | velocity_y: %0d | state: %0d", 
    $time, key_space, dut.position_y, rst, dut.cycle_counter, dut.time_passed,dut.velocity_y, dut.state);
end

endmodule