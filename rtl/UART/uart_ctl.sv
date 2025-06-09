module uart_ctl (
        input  logic           clk,
        input  logic           rst,
        input  logic [7:0] data_tx,
        output logic [7:0] data_rx,
        output logic            rx,
        output logic            tx,
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

    logic tx_uart;

    logic db_level, db_tick;

    logic [0:3] hex0, hex1, hex2, hex3;


    /**
     * Signals assignments
     */


     assign rd_uart = !rx_empty;

     always_ff @(posedge clk) begin
        if (rst) begin
            rx_monitor <= 1'b0;
            tx_monitor <= 1'b0;
        end else begin
            rx_monitor <= RsRx;
            tx_monitor <= RsTx;
        end
     end

    /**
     * Submodules instances
     */

    uart #(
        .DBIT(8), .SB_TICK(16), .DVSR(54), .DVSR_BIT(7), .FIFO_W(1)
    ) uart_inst (
        .clk(clk),
        .reset(rst),
        .rx(RsRx),
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
        .db_tick(db_tick),
        .hex1_data(hex1),
        .hex0_data(hex0),
        .w_data(w_data),
        .wr_uart(wr_uart)
    );

endmodule
