module data_tx (
    input  logic        clk,
    input  logic        rst,
    input  logic        db_tick,
    input  logic [3:0]  hex1_data,
    input  logic [3:0]  hex0_data,
    output logic [7:0]  w_data,   
    output logic        wr_uart
);

logic [7:0] w_data_nxt;
logic wr_uart_nxt;

always_ff @(posedge clk) begin
    if (rst) begin
        w_data <= 8'h00;
        wr_uart <= 1'b0;
    end else begin
        w_data <= w_data_nxt;
        wr_uart <= wr_uart_nxt;
    end
end

always_comb begin
    if (db_tick) begin
        w_data_nxt = {hex1_data, hex0_data} + 3;
        wr_uart_nxt = 1'b1;
    end else begin
        w_data_nxt = '0;
        wr_uart_nxt = 1'b0;
    end
end

endmodule