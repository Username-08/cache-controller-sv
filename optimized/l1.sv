module l1 #(
    parameter LINE_SIZE  = 16,
    parameter INDEX_SIZE = 4,
    parameter TAG_SIZE   = 28,
    parameter WORD_SIZE  = 32
) (
    input clk,
    input rst,
    input wr_en,
    input [WORD_SIZE - 1:0] addr,
    input [WORD_SIZE - 1:0] data,
    output logic [WORD_SIZE - 1:0] data_out,
    output logic hit_or_miss
);

  logic [TAG_SIZE + WORD_SIZE:0] l1_cache[LINE_SIZE];
  logic [INDEX_SIZE - 1:0] index;
  logic [TAG_SIZE - 1:0] tag;

  logic cycle;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      cycle <= 0;
      data_out <= 0;
      hit_or_miss <= 0;
      // reset all values in cache
      for (int i = 0; i < LINE_SIZE; i++) begin
        l1_cache[i] <= {1'b0, {TAG_SIZE{1'b0}}, {WORD_SIZE{1'b0}}};
      end
    end else begin
      // cycle 1, assign tag, index
      if (cycle == 0) begin
        tag <= addr[WORD_SIZE-1:WORD_SIZE-TAG_SIZE];
        index <= addr[WORD_SIZE-TAG_SIZE-1:WORD_SIZE-TAG_SIZE-INDEX_SIZE];
        cycle <= 1;
        hit_or_miss <= 0;
      end  // cycle 2, check hit or miss
    else begin
        cycle <= 0;
        if (wr_en) begin
          hit_or_miss <= 1;
          l1_cache[index] <= {1'b1, tag, data};
          data_out <= data;
        end else begin
          // read operation
          // check if the cache line is valid
          if (l1_cache[index][TAG_SIZE+WORD_SIZE] == 0) begin
            hit_or_miss <= 0;
            data_out <= 0;
          end  // check if the tag matches
        else if (l1_cache[index][TAG_SIZE+WORD_SIZE] == 1 &&
                 l1_cache[index][TAG_SIZE+WORD_SIZE-1:WORD_SIZE] == tag)
        begin
            hit_or_miss <= 1;
            data_out <= l1_cache[index][WORD_SIZE-1:0];
          end  // check if the tag does not match
        else begin
            hit_or_miss <= 0;
            data_out <= 0;
          end
        end
      end
    end
  end


endmodule
