module l2 #(
    parameter LINE_SIZE  = 16,
    parameter INDEX_SIZE = 4,
    parameter TAG_SIZE   = 26,
    parameter SET_SIZE   = 4,
    // parameter SET_BIT = 2,
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

  logic [TAG_SIZE + WORD_SIZE:0] l2_cache[LINE_SIZE][SET_SIZE];
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
        l2_cache[i][0] <= {1'b0, {TAG_SIZE{1'b0}}, {WORD_SIZE{1'b0}}};
        l2_cache[i][1] <= {1'b0, {TAG_SIZE{1'b0}}, {WORD_SIZE{1'b0}}};
      end
    end else begin

      // cycle 1, assign tag, index
      if (cycle == 0) begin
        tag <= addr[WORD_SIZE-1:WORD_SIZE-TAG_SIZE];
        index <= addr[WORD_SIZE-TAG_SIZE-1:WORD_SIZE-TAG_SIZE-INDEX_SIZE];
        cycle <= 1;
        hit_or_miss <= 0;
        data_out <= 0;
      end  // cycle 2, check hit or miss
    else begin
        cycle <= 0;
        if (wr_en) begin
          hit_or_miss <= 1;
          // check which set is empty
          for (int i = 0; i < SET_SIZE; i++) begin
            // if the set is empty, write data
            if (l2_cache[index][i][TAG_SIZE+WORD_SIZE] == 0) begin
              l2_cache[index][i] <= {1'b1, tag, data};
              data_out <= data;
              break;
            end
          end
        end  // read operation
      else begin
          // find set with valid bit that matches tag
          for (int i = 0; i < SET_SIZE; i++) begin
            if (l2_cache[index][i][TAG_SIZE+WORD_SIZE] == 1 &&
              l2_cache[index][i][TAG_SIZE+WORD_SIZE-1:WORD_SIZE] == tag) begin
              // write data to output
              hit_or_miss <= 1;
              data_out <= l2_cache[index][i][WORD_SIZE-1:0];
              break;
            end
          end

        end
      end
    end
  end


endmodule
