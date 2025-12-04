`timescale 1ns / 1ps

module tb_adaptive_fifo;

    reg clk = 0, rst = 1;
    reg wr_en = 0, rd_en = 0;
    reg [7:0] wr_data = 0;
    wire [7:0] rd_data;
    wire full, almost_full, empty, almost_empty;
    wire [6:0] data_count, peak_usage;
    wire [15:0] total_writes, total_reads;

    // Instantiate FIFO: depth = 2^6 = 64, data width = 8
    adaptive_fifo #(8, 6) fifo (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .full(full),
        .almost_full(almost_full),
        .empty(empty),
        .almost_empty(almost_empty),
        .data_count(data_count),
        .peak_usage(peak_usage),
        .total_writes(total_writes),
        .total_reads(total_reads)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    initial begin
        // VCD waveform dump
        $dumpfile("adaptive_fifo.vcd");
        $dumpvars(1, tb_adaptive_fifo);  // Includes internal hierarchy like 'fifo'
        $dumpvars(1, fifo);              // Explicitly dump internal signals in FIFO

        $display("Time\twr_en\twr_data\trd_en\trd_data\tcount\tfull\tempty");
        $monitor("%0t\t%b\t%h\t%b\t%h\t%d\t%b\t%b",
                  $time, wr_en, wr_data, rd_en, rd_data, data_count, full, empty);

        // Reset
        #10 rst = 0;

        // Write 10 values
        repeat (10) begin
            @(posedge clk);
            wr_en = 1;
            wr_data = wr_data + 1;
        end
        @(posedge clk);
        wr_en = 0;

        // Gap before reading
        #20;

        // Read 5 values
        repeat (5) begin
            @(posedge clk);
            rd_en = 1;
        end
        @(posedge clk);
        rd_en = 0;

        // Final wait and end simulation
        #50;
        $finish;
    end

endmodule 
