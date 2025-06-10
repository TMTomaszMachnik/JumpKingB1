module uart_ctl (
        input  logic           clk,
        input  logic           rst,
        input  logic [7:0] data_in,
        input logic             rx,
        input logic             sync_in,
        input logic             local_sync,

        output logic            tx,
        output logic [7:0] data_out
    );

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals
     */

    logic [7:0] r_data;
    logic [7:0] w_data;
    logic       rx_empty, tx_full;
    logic       rd_uart, wr_uart;
    logic tx_nxt;
    logic [7:0] data_out_nxt;

    logic tx_uart;

    /**
     * Signals assignments
     */
     always_ff @(posedge clk) begin
        if (rst) begin
            tx <= '0;
            data_out <= '0;
        end else begin
            tx <= tx_nxt;
            data_out <= data_out_nxt;
        end
     end

     assign rd_uart = !rx_empty;
     assign tx_nxt = tx_uart;
     assign data_out_nxt = r_data;

    /**
     * Submodules instances
     */

    uart #(
        .DBIT(8), .SB_TICK(16), .DVSR(54), .DVSR_BIT(7), .FIFO_W(1)
    ) uart_inst (
        .clk(clk),
        .reset(rst),
        .rx(rx),
        .tx(tx_uart),
        .rx_empty(rx_empty),
        .tx_full(tx_full),
        .rd_uart(rd_uart),
        .wr_uart(wr_uart),
        .r_data(r_data),
        .w_data(w_data)
    );

    data_tx data_tx_inst (
        .clk(clk),
        .rst(rst),
        .sync_in(sync_in),
        .local_sync(local_sync),
        .tx_full(tx_full),
        .data_in(data_in),
        .w_data(w_data),
        .wr_uart(wr_uart),
        .r_data(r_data)
    );

endmodule
