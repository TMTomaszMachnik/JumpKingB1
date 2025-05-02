module keyboard_ctl_prog (
    input logic clk,         
    input logic rst,          
    output logic key_space,
    output logic key_right,
    output logic key_left
);


localparam CTR_MAX = 500_000;

logic [31:0] counter;
logic [31:0] counter_nxt;
logic key_space_nxt;
logic key_right_nxt;
logic key_left_nxt;




always_ff @(posedge clk) begin
    if(rst) begin
        key_space <= '0;
        key_right <= '0;
        key_left <= '0;
        counter <= '0;
    end
    else begin
        key_space <=  key_space_nxt;
        key_right <=  key_right_nxt;
        key_left <=  key_left_nxt;
        counter <= counter_nxt;
    end
end


always_comb begin
    if(counter == CTR_MAX || counter == CTR_MAX*5) begin
        key_space_nxt = 1;
    end
    else begin
        key_space_nxt = 0;
    end
    key_right_nxt = 0;
    key_left_nxt = 0;
    counter_nxt = counter + 1;
end




endmodule