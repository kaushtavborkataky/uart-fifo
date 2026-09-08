module uart_tx #(
    parameter CLKS_PER_BIT = 10417
)(
    input       clk,
    input       reset,
    input       start,
    input [7:0] data_in,
    output reg  tx,
    output reg  busy
);

    reg [13:0] clk_count;
    reg [3:0]  bit_count;
    reg [7:0]  data_reg;

    always @(posedge clk) begin

        if (reset) begin
            tx        <= 1'b1;
            busy      <= 1'b0;
            clk_count <= 0;
            bit_count <= 0;
            data_reg  <= 0;
        end

        else begin

            // Start a new transmission
            if (start && !busy) begin
                busy      <= 1'b1;
                data_reg  <= data_in;
                bit_count <= 0;
                clk_count <= 0;
                tx        <= 1'b0;       // START bit
            end

            else if (busy) begin

                // Wait for one UART bit period
                if (clk_count < CLKS_PER_BIT - 1) begin
                    clk_count <= clk_count + 1'b1;
                end

                else begin
                    clk_count <= 0;

                    // Send 8 data bits
                    if (bit_count < 8) begin
                        tx <= data_reg[bit_count];
                        bit_count <= bit_count + 1'b1;
                    end

                    // Send STOP bit
                    else begin
                        tx   <= 1'b1;
                        busy <= 1'b0;
                    end
                end
            end
        end
    end

endmodule
