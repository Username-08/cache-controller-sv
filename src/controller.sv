module controller #(
    parameter WORD_SIZE = 32,
    parameter L1_DELAY  = 3,
    parameter L2_DELAY  = 3
) (
    input clk,
    input rst,
    input wr_en,
    input [WORD_SIZE - 1:0] addr,
    input [WORD_SIZE - 1:0] data,
    output logic [WORD_SIZE - 1:0] data_out
);
  logic [WORD_SIZE - 1:0] l1_out;
  logic [WORD_SIZE - 1:0] l2_out;
  logic [WORD_SIZE - 1:0] mem_out;

  logic [L1_DELAY - 1:0] l1_counter;
  logic [L2_DELAY - 1:0] l2_counter;

  logic l1_hit;
  logic l2_hit;

  logic [WORD_SIZE - 1:0] addr_prev;

  l1 l1_cache (
      .clk(clk),
      .rst(rst),
      .wr_en(wr_en),
      .addr(addr),
      .data(data),
      .data_out(l1_out),
      .hit_or_miss(l1_hit)
  );

  l2 l2_cache (
      .clk(clk),
      .rst(rst),
      .wr_en(wr_en),
      .addr(addr),
      .data(data),
      .data_out(l2_out),
      .hit_or_miss(l2_hit)
  );

  mem memory (
      .clk(clk),
      .rst(rst),
      .wr_en(wr_en),
      .addr(addr),
      .data(data),
      .data_out(mem_out)
  );



  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      l1_counter <= 0;
      l2_counter <= 0;
      data_out   <= 0;
      addr_prev  <= 0;
    end else begin
      if (addr != addr_prev) begin
        l1_counter <= 0;
        l2_counter <= 0;
        addr_prev  <= addr;
      end  // controller logic here
         // access l1 cache first
      else if (wr_en) begin
        // check if l1 and l2 have finished operating
        if (l1_counter < L1_DELAY) l1_counter <= l1_counter + 1;
        if (l2_counter < L2_DELAY) l2_counter <= l2_counter + 1;

        // l1 and l2 have set outputs
        if (l1_counter == L1_DELAY && l2_counter == L2_DELAY) begin
          data_out   <= data;
          l1_counter <= 0;
          l2_counter <= 0;
        end
      end else begin
        // read operation
        // check if l1 and l2 have finished operating
        if (l1_counter < L1_DELAY) l1_counter <= l1_counter + 1;
        if (l2_counter < L2_DELAY) l2_counter <= l2_counter + 1;

        // l1 and l2 have set outputs
        if (l1_counter == L1_DELAY && l2_counter == L2_DELAY) begin
          l1_counter <= 0;
          l2_counter <= 0;

          if (l1_hit) begin
            data_out <= l1_out;
          end else if (l2_hit) begin
            data_out <= l2_out;
          end else begin
            // l1 and l2 misses, read from memory
            data_out <= mem_out;
          end
        end
      end
    end
  end
endmodule

