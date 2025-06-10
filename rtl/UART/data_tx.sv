module data_tx (
    input  logic        clk,
    input  logic        rst,
    input  logic        sync_in,
    input  logic        local_sync,
    input  logic        tx_full,
    input  logic [7:0]  data_in,
    input  logic [7:0]  r_data,

    output logic [7:0]  w_data,   
    output logic        wr_uart
);

logic [7:0] w_data_nxt;
logic wr_uart_nxt;
logic synced;
logic synced_nxt;

always_ff @(posedge clk) begin
    if (rst) begin
        w_data <= 8'hAA;
        wr_uart <= 1'b0;
    end else begin
        w_data <= w_data_nxt;
        wr_uart <= wr_uart_nxt;
    end
end

always_ff @(posedge clk) begin
    if (rst) begin
        synced <= 1'b0;
    end else begin
        synced <= synced_nxt;
    end
end

always_comb begin
    if(local_sync && sync_in && r_data == 8'hAA) begin
        synced_nxt = 1'b1;
    end else begin
        synced_nxt = synced;
    end
end

always_comb begin
    if(synced) begin
        if (!tx_full) begin
            w_data_nxt = data_in;
            wr_uart_nxt = 1'b1;
        end else begin
            w_data_nxt = '0;
            wr_uart_nxt = 1'b0;
        end
    end else begin
         if (!tx_full) begin
            w_data_nxt = 8'hAA; // Default data to send when not synced
            wr_uart_nxt = 1'b1;
        end else begin
            w_data_nxt = '0;
            wr_uart_nxt = 1'b0;
        end
    end
    
end

endmodule