`timescale 1ns/1ps

module uart_fifo_tb;

    reg clk;
    reg reset;

    reg        tx_start;
    reg [7:0]  tx_data;

    wire       tx_serial;
    wire       tx_busy;

    reg        fifo_rd_en;
    wire [7:0] fifo_data_out;
    wire       fifo_full;
    wire       fifo_empty;

    // DUT
    uart_fifo_top #(
        .CLKS_PER_BIT(10417)
    ) uut (
        .clk           (clk),
        .reset         (reset),

        .tx_start      (tx_start),
        .tx_data       (tx_data),
        .tx_serial     (tx_serial),
        .tx_busy       (tx_busy),

        .fifo_rd_en    (fifo_rd_en),
        .fifo_data_out (fifo_data_out),
        .fifo_full     (fifo_full),
        .fifo_empty    (fifo_empty)
    );

    // 100 MHz clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Non-blocking assignment task to prevent signal races
    task send_byte;
        input [7:0] data;
        begin
            wait (!tx_busy);
            @(posedge clk);
            tx_data  <= data;
            tx_start <= 1'b1;
            @(posedge clk);
            tx_start <= 1'b0;
            $display("TX STARTED: Data = %h at %0t ns", data, $time);
            
            // Wait until transmission actually finishes before proceeding
            wait (tx_busy);
            wait (!tx_busy);
        end
    endtask

    // FIFO read and comparison task
    task read_and_check;
        input [7:0] expected_data;
        begin
            wait (!fifo_empty);

            @(posedge clk);
            fifo_rd_en <= 1'b1;
            @(posedge clk);
            fifo_rd_en <= 1'b0;
            
            // 1 cycle wait for non-FWFT FIFO output settling
            @(posedge clk);

            $display("FIFO DATA = %h", fifo_data_out);

            if (fifo_data_out == expected_data)
                $display("PASS: Received %h correctly at %0t ns", fifo_data_out, $time);
            else
                $display("FAIL: Expected %h, got %h", expected_data, fifo_data_out);
        end
    endtask

    initial begin

        // Initial conditions
        reset      = 1'b1;
        tx_start   = 1'b0;
        tx_data    = 8'h00;
        fifo_rd_en = 1'b0;

        // Reset Sequence
        #100;
        reset = 1'b0;
        @(posedge clk);

        // -----------------------------
        // Test 1: Single Byte (8'h41)
        // -----------------------------
        send_byte(8'h41);
        read_and_check(8'h41);

        // -----------------------------
        // Test 2: Consecutive Bytes
        // -----------------------------
        send_byte(8'hA5);
        read_and_check(8'hA5);

        send_byte(8'h5A);
        read_and_check(8'h5A);

        $display("Time = %0t ns", $time);
        $display("TX busy    = %b", tx_busy);
        $display("FIFO empty = %b", fifo_empty);
        $display("FIFO full  = %b", fifo_full);

        #100;
        $finish;

    end

endmodule