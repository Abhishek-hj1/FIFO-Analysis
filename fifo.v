`timescale 1ns / 1ps

module adaptive_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 6 // Default depth = 2^6 = 64
)(
    input wire clk,
    input wire rst,

    // Write interface
    input wire wr_en,
    input wire [DATA_WIDTH-1:0] wr_data,

    // Read interface
    input wire rd_en,
    output reg [DATA_WIDTH-1:0] rd_data,

    // FIFO status
    output wire full,
    output wire almost_full,
    output wire empty,
    output wire almost_empty,

    // Performance
    output reg [ADDR_WIDTH:0] data_count,     // current occupancy
    output reg [ADDR_WIDTH:0] peak_usage,     // max recorded usage
    output reg [15:0] total_writes,           // total number of writes
    output reg [15:0] total_reads             // total number of reads
);

    localparam DEPTH = 1 << ADDR_WIDTH;

    // FIFO memory
    reg [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];

    // Pointers
    reg [ADDR_WIDTH-1:0] wr_ptr = 0;
    reg [ADDR_WIDTH-1:0] rd_ptr = 0;

    // Flags
    assign empty = (wr_ptr == rd_ptr) && (data_count == 0);
    assign full  = (data_count == DEPTH);
    assign almost_full = (data_count >= (DEPTH - 2));
    assign almost_empty = (data_count <= 2);

    // Main logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            data_count <= 0;
            peak_usage <= 0;
            total_writes <= 0;
            total_reads <= 0;
            rd_data <= 0;
        end else begin
            // Write logic
            if (wr_en && !full) begin
                fifo_mem[wr_ptr] <= wr_data;
                wr_ptr <= wr_ptr + 1;
                data_count <= data_count + 1;
                total_writes <= total_writes + 1;
            end

            // Read logic
            if (rd_en && !empty) begin
                rd_data <= fifo_mem[rd_ptr];
                rd_ptr <= rd_ptr + 1;
                data_count <= data_count - 1;
                total_reads <= total_reads + 1;
            end

            // Track peak usage
            if (data_count > peak_usage)
                peak_usage <= data_count;
        end
    end
endmodule
