module l2 #(
    parameter LINE_SIZE = 16,
    parameter INDEX_SIZE = 4,
    parameter TAG_SIZE = 2,
    parameter SET_SIZE = 4,
    parameter SET_BIT = 2,
    parameter WORD_SIZE = 32
) (
    input clk,
    input wr_en,
    input [WORD_SIZE - 1:0] addr,
    input [WORD_SIZE - 1:0] data,
    output [WORD_SIZE - 1:0] data_out,
    output hit_or_miss
);

  logic [TAG_SIZE + WORD_SIZE:0] l2_cache[LINE_SIZE][SET_SIZE];
  logic [INDEX_SIZE - 1:0] index;
  logic [TAG_SIZE - 1:0] tag;

  logic hm = 0;
  logic cycle = 0;
  logic [WORD_SIZE - 1:0] dout;

  always_ff @(posedge clk) begin
    // cycle 1, assign tag, index
    if (cycle == 0) begin
      tag <= addr[WORD_SIZE-1:WORD_SIZE-TAG_SIZE];
      index <= addr[WORD_SIZE-TAG_SIZE-1:WORD_SIZE-TAG_SIZE-INDEX_SIZE];
      cycle <= 1;
      hm <= 0;
      dout <= 0;
    end  // cycle 2, check hit or miss

    else begin
      if (wr_en) begin
        hm <= 1;
        // check which set is empty
        for (int i = 0; i < SET_SIZE; i++) begin
          // if the set is empty, write data
          if (l2_cache[index][i][TAG_SIZE+WORD_SIZE] == 0) begin
            l2_cache[index][i] <= {1'b1, tag, data};
            dout <= data;
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
            hm   <= 1;
            dout <= l2_cache[index][i][WORD_SIZE-1:0];
            break;
          end
        end

      end
    end
  end

  assign hit_or_miss = hm;
  assign data_out = dout;

endmodule
