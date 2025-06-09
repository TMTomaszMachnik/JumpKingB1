module data_tx (
    input  logic        clk,
    input  logic        rst,
    input  logic        tx_full,
    input  logic [7:0]  data_in,
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
    if (!tx_full) begin
        w_data_nxt = data_in;
        wr_uart_nxt = 1'b1;
    end else begin
        w_data_nxt = '0;
        wr_uart_nxt = 1'b0;
    end
end

endmodule