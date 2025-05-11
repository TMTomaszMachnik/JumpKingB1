module keyboard_ctl_tb();

`timescale 1ns / 1ps

localparam CLK_PERIOD = 25; //40Mhz
localparam CLK100_PERIOD = 10; //100Mhz

logic clk, rst,clk100;

logic [11:0] x_out;
logic [11:0] y_out;
logic key_space;
logic key_right;
logic key_left;
logic ps2_clk;
logic ps2_data;
logic counter = 0;

initial begin
    clk = 1'b0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

initial begin
    clk100 = 1'b0;
    forever #(CLK100_PERIOD/2) clk100 = ~clk100;
end

initial begin
    rst = 1'b0;
    #(1.25*CLK_PERIOD) rst = 1'b1;
    rst = 1'b1;
    #(2.00*CLK_PERIOD) rst = 1'b0;
end


keyboard_ctl dut_key(
    .clk(clk100),
    .rst(rst),
    .key_space(key_space),
    .key_right(key_right),
    .key_left(key_left),
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data)
);


draw_rect_ctl dut(
    .clk(clk100),
    .rst(rst),
    .key_space(key_space),
    .key_right(key_right),
    .key_left(key_left),
    .value_x(x_out),
    .value_y(y_out)
);

initial begin
    @(negedge rst);

#100;
    force dut_key.u_ps2_receiver.keycode = 16'h29;
    force dut_key.u_ps2_receiver.oflag = 1'b1; 
    #100
    release dut_key.u_ps2_receiver.keycode; 
    release dut_key.u_ps2_receiver.oflag; 

    force dut_key.u_ps2_receiver.keycode = 16'hF029; 
    force dut_key.u_ps2_receiver.oflag = 1'b1; 
    #1600;

    force dut_key.u_ps2_receiver.keycode = 16'h29;
    force dut_key.u_ps2_receiver.oflag = 1'b1; 
    #100
    release dut_key.u_ps2_receiver.keycode; 
    release dut_key.u_ps2_receiver.oflag; 

    force dut_key.u_ps2_receiver.keycode = 16'hF029; 
    force dut_key.u_ps2_receiver.oflag = 1'b1; 

end


initial begin
    $monitor("Time: %0t | key_space: %b | position_y: %0d | rst: %0d | cycle_counter: %0d | time_passed: %0d | velocity_y: %0d | state: %0d | space_state: %0h", 
        $time, key_space, dut.position_y, rst, dut.cycle_counter, dut.time_passed, dut.velocity_y, dut.state, dut_key.u_ps2_receiver.keycode);
end

endmodule