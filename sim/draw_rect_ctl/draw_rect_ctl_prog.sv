module draw_rect_ctl_prog(

    input logic clk,
    input logic rst,

    output logic mouse_left,
    output logic [11:0] mouse_xpos,
    output logic [11:0] mouse_ypos

);

localparam CTR_MAX = 500_000;

logic [31:0] counter;
logic [31:0] counter_nxt;
logic mouse_left_nxt;
logic [11:0] mouse_xpos_nxt;
logic [11:0] mouse_ypos_nxt;


always_ff @(posedge clk) begin
    if(rst) begin
        mouse_left <= '0;
        mouse_xpos <= '0;
        mouse_ypos <= '0;
        counter <= '0;
    end
    else begin
        mouse_left <=  mouse_left_nxt;
        mouse_xpos <=  mouse_xpos_nxt;
        mouse_ypos <=  mouse_ypos_nxt;
        counter <= counter_nxt;
    end
end


always_comb begin
    if(counter >= CTR_MAX) begin
        mouse_left_nxt = 1;
    end
    else begin
        mouse_left_nxt = 0;
    end
    mouse_xpos_nxt = 0;
    mouse_ypos_nxt = 0;
    counter_nxt = counter + 1;
end


endmodule