module data_tx (
    input  logic        clk,
    input  logic        rst,
    input  logic        tx_full_1,
    input  logic [7:0]  data_in_1,
    output logic [7:0]  w_data_1,   
    output logic        wr_uart_1,

    input  logic        tx_full_2,
    input  logic [7:0]  data_in_2,
    output logic [7:0]  w_data_2,   
    output logic        wr_uart_2,

    input  logic        tx_full_3,
    input  logic [7:0]  data_in_3,
    output logic [7:0]  w_data_3,   
    output logic        wr_uart_3
);

logic [7:0] w_data_nxt_1;
logic wr_uart_nxt_1;
logic [7:0] w_data_nxt_2;  
logic wr_uart_nxt_2;
logic [7:0] w_data_nxt_3;
logic wr_uart_nxt_3;


always_ff @(posedge clk) begin
    if (rst) begin
        w_data_1 <= 8'b01000110;
        wr_uart_1 <= 1'b0;
        w_data_2 <= 8'b00001000;
        wr_uart_2 <= 1'b0;
        w_data_3 <= 8'b0010100;
        wr_uart_3 <= 1'b0;

    end else begin
        w_data_1 <= w_data_nxt_1;
        wr_uart_1 <= wr_uart_nxt_1; 
        w_data_2 <= w_data_nxt_2;
        wr_uart_2 <= wr_uart_nxt_2;
        w_data_3 <= w_data_nxt_3;
        wr_uart_3 <= wr_uart_nxt_3;
    end
end

always_comb begin
    if (!tx_full_1) begin
        w_data_nxt_1 = data_in_1;
        wr_uart_nxt_1 = 1'b1;
    end else begin
        w_data_nxt_1 = 8'b0;
        wr_uart_nxt_1 = 1'b0;
    end

    if (!tx_full_2) begin
        w_data_nxt_2 = data_in_2;
        wr_uart_nxt_2 = 1'b1;
    end else begin
        w_data_nxt_2 = 8'b0;
        wr_uart_nxt_2 = 1'b0;
    end

    if (!tx_full_3) begin
        w_data_nxt_3 = data_in_3;
        wr_uart_nxt_3 = 1'b1;
    end else begin
        w_data_nxt_3 = 8'b0;
        wr_uart_nxt_3 = 1'b0;
    end
end

endmodule