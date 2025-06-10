module uart_ctl (
        input  logic           clk,
        input  logic           rst,
        input  logic [7:0] data_in_1,
        input  logic [7:0] data_in_2,
        input  logic [7:0] data_in_3,
        input logic             rx_1,
        input logic             rx_2,
        input logic             rx_3,

        output logic            tx_1,
        output logic            tx_2,
        output logic            tx_3,

        output logic [7:0] data_out_1,
        output logic [7:0] data_out_2,
        output logic [7:0] data_out_3
    );

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals
     */

    logic [7:0] r_data_1;
    logic [7:0] w_data_1;
    logic       rx_empty_1, tx_full_1;
    logic       rd_uart_1, wr_uart_1;
    logic tx_nxt_1;
    logic [7:0] data_out_nxt_1;
    logic tx_uart_1;
    
    logic [7:0] r_data_2;
    logic [7:0] w_data_2;
    logic       rx_empty_2, tx_full_2;
    logic       rd_uart_2, wr_uart_2;
    logic tx_nxt_2;
    logic [7:0] data_out_nxt_2;
    logic tx_uart_2;

    logic [7:0] r_data_3;
    logic [7:0] w_data_3;
    logic       rx_empty_3, tx_full_3;
    logic       rd_uart_3, wr_uart_3;
    logic tx_nxt_3;
    logic [7:0] data_out_nxt_3;
    logic tx_uart_3;

    /**
     * Signals assignments
     */
     always_ff @(posedge clk) begin
        if (rst) begin
            tx_1 <= 1'b0;
            tx_2 <= 1'b0;
            tx_3 <= 1'b0;
            data_out_1 <= 8'b0;
            data_out_2 <= 8'b0;
            data_out_3 <= 8'b0;

        end else begin
            tx_1 <= tx_nxt_1;
            tx_2 <= tx_nxt_2;
            tx_3 <= tx_nxt_3;
            data_out_1 <= data_out_nxt_1;
            data_out_2 <= data_out_nxt_2;
            data_out_3 <= data_out_nxt_3;
        end
     end

     assign rd_uart_1 = !rx_empty_1;
     assign tx_nxt_1 = tx_uart_1;
     assign data_out_nxt_1 = r_data_1;

     assign rd_uart_2 = !rx_empty_2;
     assign tx_nxt_2 = tx_uart_2;
     assign data_out_nxt_2 = r_data_2;

     assign rd_uart_3 = !rx_empty_3;
     assign tx_nxt_3 = tx_uart_3;
     assign data_out_nxt_3 = r_data_3;

    /**
     * Submodules instances
     */

    uart #(
        .DBIT(8), .SB_TICK(16), .DVSR(54), .DVSR_BIT(7), .FIFO_W(1)
    ) uart_inst (
        .clk(clk),
        .reset(rst),
        .rx(rx_1),
        .tx(tx_uart_1),
        .rx_empty(rx_empty_1),
        .tx_full(tx_full_1),
        .rd_uart(rd_uart_1),
        .wr_uart(wr_uart_1),
        .r_data(r_data_1),
        .w_data(w_data_1)
    );

    uart #(
        .DBIT(8), .SB_TICK(16), .DVSR(54), .DVSR_BIT(7), .FIFO_W(1)
    ) uart_inst_2 (
        .clk(clk),
        .reset(rst),
        .rx(rx_2),
        .tx(tx_uart_2),
        .rx_empty(rx_empty_2),
        .tx_full(tx_full_2),
        .rd_uart(rd_uart_2),
        .wr_uart(wr_uart_2),
        .r_data(r_data_2),
        .w_data(w_data_2)
    );

    uart #(
        .DBIT(8), .SB_TICK(16), .DVSR(54), .DVSR_BIT(7), .FIFO_W(1)
    ) uart_inst_3 (
        .clk(clk),
        .reset(rst),
        .rx(rx_3),
        .tx(tx_uart_3),
        .rx_empty(rx_empty_3),
        .tx_full(tx_full_3),
        .rd_uart(rd_uart_3),
        .wr_uart(wr_uart_3),
        .r_data(r_data_3),
        .w_data(w_data_3)
    );

    data_tx data_tx_inst (
        .clk(clk),
        .rst(rst),
        .tx_full_1(tx_full_1),
        .data_in_1(data_in_1),
        .w_data_1(w_data_1),
        .wr_uart_1(wr_uart_1),
        .tx_full_2(tx_full_2),
        .data_in_2(data_in_2),
        .w_data_2(w_data_2),
        .wr_uart_2(wr_uart_2),
        .tx_full_3(tx_full_3),
        .data_in_3(data_in_3),
        .w_data_3(w_data_3),
        .wr_uart_3(wr_uart_3)
    );

endmodule
