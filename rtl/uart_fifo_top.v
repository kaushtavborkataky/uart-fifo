module uart_fifo_top #(
    parameter CLKS_PER_BIT = 10417
)(
    input        clk,
    input        reset,

    // UART TX interface
    input        tx_start,
    input  [7:0] tx_data,
    output       tx_serial,
    output       tx_busy,

    // FIFO read interface
    input        fifo_rd_en,
    output [7:0] fifo_data_out,
    output       fifo_full,
    output       fifo_empty
);

    // Internal UART RX signals
    wire [7:0] rx_data;
    wire       rx_data_valid;
    wire       rx_frame_error;

    // Direct write-enable masked by FIFO full status to prevent buffer overflow
    wire       fifo_wr_en;
    assign fifo_wr_en = rx_data_valid & ~fifo_full;

    // UART TX Module
    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) tx_inst (
        .clk    (clk),
        .reset  (reset),
        .start  (tx_start),
        .data_in(tx_data),
        .tx     (tx_serial),
        .busy   (tx_busy)
    );

    // UART RX Module (Loopback)
    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) rx_inst (
        .clk        (clk),
        .reset      (reset),
        .rx_async   (tx_serial),
        .data_out   (rx_data),
        .data_valid (rx_data_valid),
        .frame_error(rx_frame_error)
    );

    // Synchronous FIFO Storage
    fifo fifo_inst (
        .clk      (clk),
        .reset    (reset),
        .wr_en    (fifo_wr_en),
        .rd_en    (fifo_rd_en),
        .data_in  (rx_data),
        .data_out (fifo_data_out),
        .full     (fifo_full),
        .empty    (fifo_empty)
    );

endmodule