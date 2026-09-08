module uart_rx #(
    parameter CLKS_PER_BIT = 10417
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       rx_async,
    output reg [7:0]  data_out,
    output reg        data_valid,
    output reg        frame_error
);

    // State definitions
    localparam IDLE  = 3'b000;
    localparam START = 3'b001;
    localparam DATA  = 3'b010;
    localparam STOP  = 3'b011;

    reg [2:0] state;

    // Counters
    reg [13:0] clk_count;
    reg [3:0]  bit_count;

    // Register to store received data
    reg [7:0] data_reg;

    // 2-FF synchronizer for asynchronous rx
    reg rx_q1, rx_q2;
    wire rx = rx_q2;

    always @(posedge clk) begin
        rx_q1 <= rx_async;
        rx_q2 <= rx_q1;
    end

    always @(posedge clk) begin
        if (reset) begin
            state       <= IDLE;
            clk_count   <= 0;
            bit_count   <= 0;
            data_reg    <= 0;
            data_out    <= 0;
            data_valid  <= 0;
            frame_error <= 0;
        end else begin
            case (state)
                IDLE: begin
                    data_valid  <= 1'b0;
                    frame_error <= 1'b0;
                    clk_count   <= 0;
                    bit_count   <= 0;

                    if (rx == 1'b0) begin // Start bit detected
                        state <= START;
                    end
                end

                START: begin
                    if (clk_count == (CLKS_PER_BIT - 1) / 2) begin
                        if (rx == 1'b0) begin // Confirm valid start bit at midpoint
                            clk_count <= 0;
                            state     <= DATA;
                        end else begin
                            state <= IDLE;
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                DATA: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count           <= 0;
                        data_reg[bit_count] <= rx; // Sample serial data bit

                        if (bit_count < 7) begin
                            bit_count <= bit_count + 1;
                        end else begin
                            bit_count <= 0;
                            state     <= STOP;
                        end
                    end
                end

                STOP: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count   <= 0;
                        data_out    <= data_reg;        // Latch output byte
                        data_valid  <= 1'b1;            // Pulse HIGH for 1 clock cycle
                        frame_error <= (rx == 1'b0);    // Check stop bit
                        state       <= IDLE;
                    end
                end

                default: begin
                    state       <= IDLE;
                    clk_count   <= 0;
                    bit_count   <= 0;
                    data_valid  <= 1'b0;
                    frame_error <= 1'b0;
                end
            endcase
        end
    end

endmodule
