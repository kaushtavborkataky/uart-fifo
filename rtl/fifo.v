module fifo (
    input        clk,
    input        reset,
    input        wr_en,
    input        rd_en,
    input  [7:0] data_in,
    output reg [7:0] data_out,
    output       full,
    output       empty
);

    // 4 locations, each storing 8 bits
    reg [7:0] memory [0:3];

    // 3-bit pointers:
    // [1:0] = memory address
    // [2]   = wrap bit
    reg [2:0] wr_ptr;
    reg [2:0] rd_ptr;

    // EMPTY condition
    assign empty = (wr_ptr == rd_ptr);

    // FULL condition
    assign full = (wr_ptr[1:0] == rd_ptr[1:0]) &&
                  (wr_ptr[2]   != rd_ptr[2]);

    // Read and Write operations
    always @(posedge clk) begin

        if (reset) begin
            wr_ptr   <= 3'b000;
            rd_ptr   <= 3'b000;
            data_out <= 8'b0;
        end

        else begin

            // WRITE
            if (wr_en && !full) begin
                memory[wr_ptr[1:0]] <= data_in;
                wr_ptr <= wr_ptr + 1'b1;
            end

            // READ
            if (rd_en && !empty) begin
                data_out <= memory[rd_ptr[1:0]];
                rd_ptr <= rd_ptr + 1'b1;
            end

        end
    end

endmodule