module sync_data (
    input  logic        clk,
    input  logic        rst,
    input  logic [7:0]  data_1,
    input  logic [7:0]  data_2,
    input  logic [7:0]  data_3,
    
    output logic [23:0] sync_data
);

logic sync_signal;

always_ff @(posedge clk) begin
    if (rst) begin
        sync_data <= '0;
    end else if(sync_signal) begin
        // Synchronize the data inputs
        sync_data <= {data_3, data_2, data_1};
    end else begin
        sync_data <= '0;
    end
end

always_comb begin
    // Logic to determine the next state of sync_signal
    if (data_1 == 4'hAA &&  data_2 == 4'hAA && data_3 == 4'hAA) begin
        sync_signal= 1'b1; // All data inputs match
    end
end

endmodule