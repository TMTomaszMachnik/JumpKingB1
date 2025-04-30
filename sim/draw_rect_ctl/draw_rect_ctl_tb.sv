module draw_rect_ctl_tb();

`timescale 1ns / 1ps

localparam CLK_PERIOD = 10; //100Mhz

logic clk, rst;
logic mouse_left;
logic [11:0] mouse_x;
logic [11:0] mouse_y;

logic [11:0] x_out;
logic [11:0] y_out;

initial begin
    rst = 1'b0;
    clk = 1'b0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end


initial begin
    rst = 1'b0;
    #(1.25*CLK_PERIOD) rst = 1'b1;
    rst = 1'b1;
    #(2.00*CLK_PERIOD) rst = 1'b0;
end


draw_rect_ctl_prog dut_ctrl(
    .clk,
    .rst,
    .mouse_left(mouse_left),
    .mouse_xpos(mouse_x),
    .mouse_ypos(mouse_y)
);

draw_rect_ctl dut(
    .clk,
    .rst,
    .mouse_left(mouse_left),
    .mouse_xpos(mouse_x),
    .mouse_ypos(mouse_y),
    .xpos(x_out),
    .ypos(y_out)
);


always_comb begin
        $display("mouse_left: %b", mouse_left);
        $display("x_out: %d", x_out);
        $display("y_out: %d", y_out);
        $display("time[ms] : %d", dut.vel_time*10);
        $display("velocity : %d", dut.velocity);
        $display("ypos_set : %d", dut.ypos_set);
        $display("bounce : %d", dut.bounce);
        $display("-------------------");
        if (y_out == 537) begin
            $display("Reached y_out = 537. Simulation finished.");
            $display("Time required to fall down: %d ms", $time/1_000_000);
            $finish;
        end
end

endmodule